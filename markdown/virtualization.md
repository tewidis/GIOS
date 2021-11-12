# Virtualization

Virtualization Overview

    * Virtualization allows concurrent execution of multiple OSs (and their 
    applications) on the same physical machine
        + Invented at IBM in the 1960s
    * Virtual resources: Each OS thinks that it "owns" hardware resources
    * Virtual machine: OS + applications + virtual resources (guest domain)
    * Virtualization layer: Management of physical hardware (virtual machine 
    monitor, hypervisor)

Defining Virtualization

    * Virtual machine: An efficient, isolated duplicate of the real machine
    * Supported by a virtual machine monitor (VMM)
        1. Provides environment essentially identical with the original machine
        2. Programs show at worst only minor decrease in speed
        3. VMM is in complete control of system resources
    * VMM goals: Fidelity, Performance, Safety/Isolation

Benefits of Virtualization

    * Consolidation: Can run multiple VMs with separate OS and applications on a
    single physical platform
        + Decrease cost, improve manageability
    * Migration: Move OS/applications from one physical machine to another
        + Availability, reliability
    * Security: Malicious behavior is contained to one instance
    * Debugging: Can quickly introduce new OS feature and test it
    * Support for legacy OSs

Virtualization Models

    * Bare Metal/Hypervisor (type 1)
        + VMM (hypervisor) manages all hardware resources and supports execution
        of VMs
        + Priveled, service VM to deal with devices (and other configuration and
        management tasks)
        + Xen (open source of Citrix XenServer)
            - VMs are referred to as domains
            - dom0 is priveleged domain
            - domUs is guest domains
            - Drivers in dom0
        + ESX (VMware)
            - Many open APIs
            - Drivers in VMM
            - Used to have Linux control core, now remote APIs
    * Hosted (type 2)
        + Host OS owns all hardware
        + Special VMM module provides hardware interfaces to VMs and deals with
        VM context switching
        + KVM (kernel-based VM)
            - Based on Linux
            - KVM kernel module + QEMU for hardware virtualization
            - Leverages Linux open-source community

| ![baremetal](images/bare_metal.png) |
|:--:|
| Bare Metal Virtualization Model |

| ![hosted](images/hosted.png) |
|:--:|
| Hosted Virtualization Model |

Hardware Protection Levels

    * Commodity hardware has more than two protection levels
        + x86 has 4 protection levels (rings)
            - ring 0: Highest privelege (OS)
            - ring 3: Lowest privelege (applications)
        + For virtualization:
            - ring 0: Hypervisor
            - ring 1: OS
            - ring 3: Applications
        + x86 also has 2 protection modes
            - Non-root: VMs (ring 0: OS, ring 3: applications)
            - Root: (ring 0: hypervisor)
            - VMexit: Trap to root mode
            - VMentry: Return to non-root mode

Processor Virtualization

    * Guest instructions
        + Executed directly by hardware (VMM doesn't interfere)
        + For non-priveleged operations: Hardware speeds -> efficiency
        + For priveleged operations: Trap to hypervisor
        + Hypervisor determines what needs to be done
            - If illegal oepration: Terminate VM
            - If legal operation: Emulate the behavior the guest OS was 
            expecting from the hardware
    * Called trap-and-emulate; key component in achieving efficiency

x86 Virtualization in the Past

    * Problems with Trap-and-Emulate (x86 pre-2005)
        + 4 rings, no root/non-root modes yet
        + Hypervisor in ring0, guest OS in ring1
        + 17 privelegd instructions do not trap! Fail silently!
            - Interrupt enable/disable bit in priveleged register;
            POPF/PUSHF instructions that access it from ring1 fail silently
            - Hypervisor doesn't know, so it doesn't try to change settings
            - OS doesn't know, so it assumes the change was successful

Binary Translation

    * Main idea: Rewrite the VM binary to never issue those 17 instructions
        + Pioneered by Mendel Rosenblum's group at Stanford, commercialized as
        VMware (received ACM fellow for "reinventing virtualization")
    * Binary translation:
        + Goal: Full virtualization == guest OS is not modified
        + Approach: Dynamic binary translation
        1. Inspect code blocks to be executed
        2. If needed, translate to alternate instruction sequence
            - e.g., to emulate desired behavior, possibly even avoiding trap
        3. Otherwise, run at hardware speeds
            - Cache translated blocks to amortize translation costs

Paravirtualization

    * Goal: Performance, but give up on running unmodified guests
    * Approach: Modify guest so that it...
        + knows it's running virtualized
        + makes explicit calls to the hypervisor (hypercalls)
    * Hypercalls are analogous to system calls
        + Package context information
        + Specify desired hypercall
        + Trap to VMM
    * Xen: Open source hypervisor (XenSource -> Citrix)

Full Memory Virtualization

    * Full virtualization
        + All guests expect contiguous physical memory, starting at 0
        + Virtual vs physical vs machine addresses and page frame numbers
        + Still leverages hardware MMU, TLB
    * Option 1
        + Essentially two page tables; One for OS, one for hypervisor
        + Guest page table: VA -> PA (software)
        + Hypervisor: PA -> MA (hardware)
        + Too expensive!
    * Option 2
        + Guest page table: VA -> PA
        + Hypervisor shadow PT: VA -> MA
        + Hypervisor maintains consistence
            - e.g., invalidate on context switch, write-protect guest page table
            to track new mappings

Paravirtualized Memory Virtualization

    * Paravirtualized
        + Guest is aware of virtualization
        + No longer strict requirement on contiguous physical memory starting 
        at 0
        + Explicitly registers page tables with hypervisors
        + Can "batch" page table updates to reduce VM exits and other 
        optimizations
    * Overheads are eliminated or reduced on newer platforms

Device Virtualization

    * For CPUs and memory:
        + Less diversity at the ISA-level ("standardization" of interface)
    * For devices:
        + High diversity
        + Lack of standard specification of device interface and behavior
    * 3 Key Models for device virtualization (pre-virtualization HW extensions)

Passthrough Model

    * Approach: VMM-level driver configures device access permissions
    * Pros:
        + VM provided with exclusive access to the device
        + VM can directly access the device (VMM-bypass)
    * Cons:
        + Device sharing is difficult
        + VMM must have exact type of device as what VM expects
        + VM migration becomes more difficult

| ![passthrough](images/passthrough_model.png) |
|:--:|
| Hosted Virtualization Model |

Hypervisor-Direct Model

    * Used by VMware ESX
    * Approach: VMM intercepts all device accesses
        + Emulate device operation:
            - Translate to generic I/O operation
            - Traverse VMM-resident I/O stack
            - Invoke VMM-resident driver
    * Pros: 
        + VM decoupled from physical device
        + Sharing, migration, dealing with device specifics all become simpler
    * Cons: 
        + Latency of device operations
        + Device driver ecosystem complexities in hypervisor

| ![hypervisordirect](images/hypervisor_direct_model.png) |
|:--:|
| Hypervisor-Direct Virtualization Model |

Split-Device Driver Model

    * Approach: Device access control split between...
        + Front-end driver in guest VM (device API)
        + Back-end driver in service VM (or host)
        + Modified guest drivers to interact with back-end
    + Pros:
        + Eliminate emulation overhead
        + Allow for better management of shared devices
    * Cons:
        + Limited to paravirtualized guests

| ![splitdevice](images/split_device_model.png) |
|:--:|
| Split-Device Virtualization Model |

Hardware Virtualization

    * AMD Pacifica & Intel Vanderpool Technology (Intel-VT) circa 2005
        + Close holes in x86 ISA
        + Modes: root/non-root (or 'host' and 'guest' mode)
        + VM Control Structure
            - Per vCPU; 'walked' by hardware (can specify whether a system call
            should trap or not)
        + Extended page tables and tagged TLB with VM IDs
            - Context switch between VMs ("world switch") doesn't have to flush 
            TLB; MMU can check if the address is valid for this VM
            - Context switches are much more efficient
        + Multiqueue devices and interrupt routing
            - Can deliver an interrupt to a specific VM
        + Security and management support
            - Protect VMs from each other
    * Added new instructions to x86 to exercise the above features
        + Manipulate state in VM control data structure

 x86 Virtualization Technology (VT) Revolution

| ![vtrevolution](images/vt_revolution.png) |
|:--:|
| Virtualization Revolution |
