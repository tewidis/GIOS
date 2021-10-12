# Memory Management

Operating system manages memory for all processes

    * Uses intelligently sized containers (memory pages or segments)
    * Processes operate on a subset of memory
    * Optimized for performance - Reduce time to access state in memory

Goals of Memory Management

    * Operating system manages physical resources (DRAM) for one or more processes
    * Processes use virtual address, which maps to a physical addres
        + Virtual addresses >> Physical addresses
        + Allocate physical memory and arbitrate how it's accessed
            - Allocate - Allocation, replacement
            - Arbitrate - Address translation and validation
        + OS must decide what should be moved from disk to memory and vice versa
    * Page-based memory management
        + Virtual address space partitioned into pages
        + Physical address space partitioned into page frames
        + Allocate: Pages -> Page frames
        + Arbitrate: Page tables
    * Segment-based memory management
        + Allocate: Segments (flexibly sized)
        + Arbitrate: Segment registers

Hardware Support

    * Memory management handled by hardware in addition to operating system
    * CPU contains memory management unit (virtual -> physical addresses)
        + Reports faults: Memory address requested hasn't been allocated
        + Permission: Not allowed to access memory (no write permissions)
        + Page fault: Page not present in memory, fetch from disk
    * Registers for address translation
        + Page-based: Pointers to page table
        + Segment-based: Base address and limit size, number of segments
    + Cache: Translation Lookaside Buffer (TLB)
        - Cache of valid VA-PA translations
    + Translation: Actual PA generation done in hardware

| ![hardware](images/memory_management_unit.png) |
|:--:|
| Memory Management Unit |

Page Tables
    
    * Pages are more popular method of memory management
    * Page tables convert virtual memory addresses to physical memory addresses
    * "Map" of where in memory to find virtual memory addresses
    * Virtual memory pages and physical memory page frames are the same size
        + Allows us to only translate the first address, others are just offset
    * Only the first portion of the virtual address corresponds to the page number
        + Virtual address: Virtual page number (VPN) + offset
        + Page table maps virtual page number to physical frame number (PFN)
        + Physical address: Physical frame number + offset
        + Valid bit (in memory = 1, not in memory = 0)
    * Allocation on first touch: Only allocate physical memory when accessed, 
    not when allocated
    * Unused pages can be reclaimed by the OS after some duration
    * If a mapping is invalid (valid bit == 0), TRAP occurs and OS intervenes
        + Is access permitted? Where is the page located? Where should it be 
        brought into DRAM?
    * Each process has a page table
        + Every context switch requires switching to valid page table
        + Hardware assists: Register pointing to active page table (CR3 on x86)

| ![pagetables](images/page_tables.png) |
|:--:|
| Page Table |

Page Table Entry

    * Page Frame Number
    * Flags
        + Present (valid/invalid)
        + Dirty (set when written to, indicates cached file should be updated on disk)
        + Accessed (has been accessed for read or write)
        + Protection bits (read, write, execute)
    * Page Table Entry on x86
        + P: Present
        + D: Dirty
        + A: Accessed
        + R/W: Permission bit (0 -> Read only, 1 -> Read/write)
        + U/S: Permission bit (0 -> usermode, 1 -> Supervisor mode)
        + Others: Caching related info (write through, caching disabled)
        + Unused: For future use
    * If hardware determines physical memory access can't be performed using the
    permission bits, it causes a page fault (error code on kernel stack)
        + CPU generates a TRAP into the OS kernel
        + This generates a page fault handler
            - Determines action based on error code and faulting address
            - Can bring page from disk into memory
            - Protection error (SIGSEGV)
        + On x86
            - Error code from PTE flags
            - Faulting address in CR2

| ![pagetableentry](images/page_table_entry.png) |
|:--:|
| Page Table Entry |

Page Table Size

    * 32-bit architecture
        + Page Table Entry (PTE): 4 bytes, including PFN + flags
        + Virtual Page Number (VPN): 2^32 / Page size
        + Page Size: 4 kB
        + ( 2^32 / 2^12 ) = 4 MB per process
    * Process doesn't use entire address space
    * Even on 32-bit architecture, won't always use all of 4 MB
    * Page table assumes an entry per VPN, regardless of whether corresponding
    virtual memory is needed or not

Hierarchical Page Tables

    * Outer Page Table: Page table directory (pointers to page tables)
    * Internal Page Table: Only for valid virtual memory regions
    * On malloc, a new internal page table may be allocated
    * 12 bits for outer page table, 10 bits for internal page table, 10 bits offset
        + 2^10 * page size = 2^10 * 2^10 = 1MB
        + Don't require an inner table for each 1MB virtual memory gap
        + Solves the problem of having to store so much in memory
    * Additional layers
        + 3rd level: Page table directory pointer
        + 4th level: Page table directory pointer map
        + Important on 64 bit architectures, larger and more sparse
            - Larger gaps -> Could save more internal page table components
    * Tradeoffs
        + Pro: More levels means smaller internal page tables/directories and 
        improved granularity of coverage
            - Reduced page table size
        + Con: More memory accesses required for translation
            - Increased translation latency

Translation Lookaside Buffer

    * Single level page table
        + 1x access to page table entry
        + 1x access to memory
    * Four level page table (slower)
        + 4x accesses to page table entry
        + 1x access to memory
    * Avoid repeated access to memory by caching address
    * Translation Lookaside Buffer (TLB)
        + MMU-level address translation cache
        + On TLB miss -> Page table access from memory
        + Has protection validity bits
        + Small number of cached addresses can still result in high TLB hit rate
            - Due to temporal and spatial locality
    * x86 core i7
        + Per core: 64-entry data TLB, 128-entry instruction TLB
        + 512-entry shared second-level TLB

| ![invertedpagetable](images/inverted_page_table.png) |
|:--:|
| Inverted Page Table |

Inverted Page Tables

    * Use pid to index into page table; index + offset gets physical memory address
    * Must perform linear search of pids (table isn't ordered)
    * TLB catches most of the memory references, so search is infrequent
    * Hashing page tables can help solve this problem
        + Hash points to a linked list
    * Speeds up address translation

Segmentation

    * Segments == arbitrary granularity
        + Correspond to code, heap, data, stack....
        + Address == segment selector + offset
    * Segment == continuous physical memory
        + Segment size == segment base + limit registers
    * Segementation is used with paging; address passed to paging unit to 
    compute physical address
    * Intel x86 (32 bit) -> Segmentation and paging supported
        + Linux: Up to 8K per process/8K per global process
    * Intel x86 (64 bit) -> Only paging

Page Size

    * 10-bit offset -> 1kB page size
    * 12-bit offset -> 4kB page size
    * Systems generally support different page sizes
        + Linux/x86 - 4kB, 2MB, 1GB
