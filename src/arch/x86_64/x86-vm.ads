with Interfaces; use Interfaces;
with Arch; use Arch;
with Common; use Common;

package X86.Vm is 

   -- public constants & types
   type Page_Size is (Page_4K, Page_2M);


   -- TODO: generalise, uses %cr3 now (take PML4 base parameter for other roots?)
   procedure Dump_Pages;

   -- TODO: extend the setting of flags
   -- TODO: separate Virtual_Address subtype?
   function Map_Page(   PML4:    Physical_Address; 
                        VMA:     Virtual_Address; 
                        PA:      Physical_Address;
                        Size:    Page_Size) 
                        return Boolean;

  
private
   TABLE_SIZE           : constant := 2#1000#;

   -- PRESENT_MASK         : constant := 2#1#;
   -- WRITEABLE_MASK       : constant := 2#10#;
   -- USER_MASK            : constant := 2#100#;
   -- WRITETHROUGH_MASK    : constant := 2#1000#;
   -- CACHE_DISABLE_MASK   : constant := 2#1_0000#;
   -- ACCESSED_MASK        : constant := 2#10_0000#;
   -- DIRTY_MASK           : constant := 2#100_0000#;
   -- PAGE_SIZE_MASK       : constant := 2#1000_0000#;
   -- GLOBAL_MASK          : constant := 2#1_0000_0000#;



   type Level is range 1..4;
   type Entry_Index is mod 512; 
   type Table_Offsets is array(Level) of Entry_Index;
   type Address_4K_Truncate is mod 2 ** 41;
   type Entry_Type is (Page_Table_Ref, Physical_Page_Ref);
   type Table_Ref is new Unsigned_64;

   type Tables is array(Level) of Address;

   type Page_Table_Entry is record
      No_Execute:     Boolean;
      Used_Entries:   Integer range 0..512;
      Reference:      Address_4K_Truncate;
      Available:      Integer range 0..7;
      Global:         Boolean;
      Page_Size:      Boolean;
      Dirty:          Boolean;
      Accessed:       Boolean;
      Cache_Disable:  Boolean;
      Writethrough:   Boolean;
      User_Access:    Boolean;
      Writeable:      Boolean;
      Present:        Boolean;
   end record
      -- the following combinations of bits are invalid.
      with Dynamic_Predicate => 
         not ((Dirty xor Page_Size) or (Global xor Page_Size));

   for Page_Table_Entry use record 
      Present         at 0 range 0..0;
      Writeable       at 0 range 1..1;
      User_Access     at 0 range 2..2;
      Writethrough    at 0 range 3..3;
      Cache_Disable   at 0 range 4..4;
      Accessed        at 0 range 5..5;
      Dirty           at 0 range 6..6;
      Page_Size       at 0 range 7..7;
      Global          at 1 range 0..0;
      Available       at 1 range 1..3;
      Reference       at 1 range 4..44;
      Used_Entries    at 6 range 5..14;
      No_Execute      at 7 range 7..7;
   end record;
   for Page_Table_Entry'Size use 64;


   type Page_Table is array(Entry_Index) of Page_Table_Entry;
   for Page_Table'Size use 512*64;

   function Create_Mapping(   Base:          Address; 
                              Offsets:       Table_Offsets; 
                              PA:            Physical_Address;
                              Parent_Level:  Level;
                              L:             Level) 
                              return Boolean;

    
end X86.Vm;