# Introduction to Operating Systems Preview

An operating system is the piece of software that abstracts and arbitrates the underlying hardware system

    * Abstract - Simplify what the hardware actually looks like 
        + Supporting different types of speakers
        + Interchangeable access of hard disk or SSD
    * Arbitrate - Oversee and control hardware use 
        + Distributing memory between multiple processes

An operating system...

    * Directs operational resources
        + Control use of CPU, memory, peripheral devices
    * Enforces working policies
        + Fair resource access, limits to resource usage
    * Mitigates difficulty of complex tasks
        + Abstract hardware through system calls
    * Sits between hardware and applications
    * Hides hardware complexity
    * Resource management (CPU scheduling, memory management)
    * Provide isolation and protection
        + Separate processes can't access each other's memory

Operating systems examples

    * Focus on current desktop and embedded operating systems (mainly Linux)
    * Desktop - Windows, UNIX-based (Linux, Mac OSX (BSD))
    * Embedded - Android (embedded form of Linux), iOS, Symbian

Elements of Operating Systems:

    * Abstractions - process, thread, file, socket, memory page
    * Mechanisms - create, schedule, open, write, allocate
    * Policies - Least recently used (LRU), earliest deadline first (EDF)

Design Principles

    * Separation between mechanism and policy
        + Implement flexible mechanisms to support many policies (LRU, LFU, random)
    * Optimize for the common case
        + Where will the OS be used?
        + What will the user want to execute on that machine?
        + What are the workload requirements?

User/Kernel Protection Boundary

    * User-mode is unpriveleged (applications)
    * Kernel-mode is priveleged (OS), provides direct hardware access
    * User-kernel switch is supported by hardware
        + TRAP instructions
        + System call interface (open - files, send - sockets, mmap - memory)
        + Signals - Mechanism for OS to pass data into applications
    * CPU has a bit designating user- vs kernel-mode (0 = kernel, 1 = user)

System Calls Control Flow

    * Write arguments
    * Save relevant data at well-defined location
    * Make system call

User/Kernel Transitions

    * Hardware supported
        + TRAPS on illegal instructions
        + Memory accesses requiring special privelege
    * Involves a number of instructions (~50-100 ns on 2GHz Linux machine)
    * Switches locality, affects hardware cache
        + OS may need to replace data in cache with its own

Basic OS Services

    * Process management
    * Device management
    * Memory management
    * Storage management
    * Security

Common Linux System Calls

    * Process Control
        + fork()
        + exec()
        + wait()
    * File Manipulation
        + open()
        + read()
        + write()
        + close()
    * Device Manipulation
        + ioctl()
        + read()
        + write()
    * Information Maintainence
        + getpid()
        + alarm()
        + sleep()
    * Communication
        + pipe()
        * shmget()
        + mmap()
    * Protection
        + chmod()
        + umask()
        + chown()

Monolithic OS

    * Every possible service any application can require is part of the OS 
        + Memory management
        + Drivers
        + Scheduling
        + Filesystem for random/sequential access
    * Benefits
        + Everything included
        + Inlining, compile-time optimizations
    * Drawbacks
        + Customization, portability, manageability
        + Memory footprint
        + Performance

Modular OS

    * Basic services and APIs built-in, but other modules can be added
    * Benefits
        + Maintainability
        + Smaller footprint
        + Lower resource needs
    * Drawbacks
        + Indirection can impact performance
        + Maintainence can still be an issue

Microkernel

    * Only require the most basic primitives at the OS level (address space, threads)
    * Everything else (FS, DB, device driver) runs at user-level
    * Requires significant inter-process communication
    * Benefits
        + Size
        + Verifiability (used in embedded devices, control systems)
    * Drawbacks
        + Portability
        + Complexity of software development
        + Cost of user/kernel crossing

| ![linuxarch](images/linux_architecture.png) |
|:--:|
| Linux Architecture |

| ![macarch](images/mac_architecture.png) |
|:--:|
| Mac Architecture |
