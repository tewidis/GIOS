# Process and Process Management

A process is an instance of an executing program ("task" or "job")

    * State of execution - Program counter, stack
    * Parts/temporary holding area - Data, register state, occupies state in memory
    * May require special hardware - I/O devices

What is a process?
    
    * OS manages hardware on behalf of applications
        + Application is a program on disk, flash memory... (static entity)
        + Process is state of a program when executing while loaded in memory (active entity)
    * Process contains all the state an application needs to run
        + Stack, heap, data, code
    * Types of state:
        + Text and data (static state when process first loads)
        + Heap (dynamically created during execution)
        + Stack (grows and shrinks, LIFO queue)

| ![processlayout](images/process_layout.png) |
|:--:|
| Layout of a Process |

Virtual Memory

    * Address space is the "in memory" representation of a process
    * Page tables are the mapping of virtual to physical addresses (in DRAM)
    * A process only has knowledge of virtual addresses
        + The OS manages the translation of virtual to physical addresses using page tables
    * There is likely not enough physical memory for all state
        + 32 bits of addressability yields a 4 GB address space (per process)
        + OS manages the swapping of memory between physical memory and disk for each process
    * Two processes can have identical virtual address spaces (OS will map correctly)

Process Control Block (PCB)

    * Components
        + Program Counter - Keeps track of instruction currently being executed
        + CPU Registers - Holds variables local to the program
        + Stack pointer - Keeps track of stack-allocated state
        + List of open files
        + Memory information for virtual to physical address translation
        + Priority and scheduling information
    * Certain fields are updated when process state changes (memory limits)
    * Other fields update too frequently to track every change (program counter)
        + Instead of updating the PCB, the program counter is maintained in a register on the CPU
    * When processes switch, OS stores all relevant state in the PCB (context switch)

| ![pcbstructure](images/process_control_block.png) |
|:--:|
| Process Control Block Structure |

Context Switching
    
    * Mechanism used by the OS to switch execution from context of one process to another
    * Typically quite expensive
        + Direct costs - Number of cycles for load and store instructions
        + Indirect costs - Cache misses/ cold cache
            - Accessing cache is cycles vs 100s of cycles for memory
            - Context switching will replace cached data with new process's data

Process Lifecycle

    * New - OS performs admittance control, allocates PCB and initial resources
    * Ready - Process has resources and is ready to run, but isn't yet
    * Running - Process is executing
    * Terminated - Process is completed
    * Waiting - IO operation or waiting for event

| ![lifecycle](images/process_lifecycle.png) |
|:--:|
| Process Lifecycle Diagram |

Process Creation

    * Fork - Copies parent PCB into new child PCB
        + Child continues execution at instruction after fork
    * Exec - Replace child image
        + Load new program and start from first instruction

| ![creation](images/process_creation.png) |
|:--:|
| Process Creation Diagram |

Scheduling

    * CPU scheduler determines which one of the currently ready processes will be run next
        + Also determines how long it should run
    * Three steps to scheduling (must be done efficiently):
        + Preempt - Interrupt and save the current context
        + Schedule - Run scheduler to choose next process
        + Dispatch - Dispatch process and switch to its context
    * CPU work = Tprocess / ( Tprocess + Tscheduling )
        + Timeslice - Duration of time allocated to a process (Tprocess)

| ![creation](images/process_ready_queue.png) |
|:--:|
| Ready Queue Flowchart |

Inter-Process Communication (IPC)

    * OS must provide mechanisms for processes to interact (web server/database)
    * Transfer data/information between address spaces
    * Maintain protection and isolation
    * Provide flexibility and performance
    * Message-passing IPC
        + OS provides communication channel, like shared buffer
        + Processes write (send) and read (recv) messages to/from channel
        + OS manages this channel, but introduces some overhead
    * Shared Memory IPC
        + OS establishes a shared channel and maps it into each process address space
        + Processes directly read/write from this memory
        + OS is out of the way (no overhead), but doesn't support well-defined API
        + Memory-mapping is an expensive process
            - Only makes sense when startup cost can be amortized over many messages
