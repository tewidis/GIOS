# I/O Management

I/O Management Overview

    * Have protocols
        + Interfaces for device I/O
    * Have dedicated handlers
        + Device drivers, interrupt handlers, ...
    * Decouple I/O details from core processing
        + Abstract I/O device detail from applications

I/O Device Features

    * Control Registers
        + Command
        + Data transfers
        + Status
    * Microcontroller == Device's CPU
    * On device memory
    * Other logic (ADC, DAC, etc.)

CPU/Device Interconnect

    * Peripheral Component Interconnect (PCI)
        + Standard method for connecting devices to CPU
        + PCI-X: PCI Extended (better than PCI)
        + PCIE: PCI Express (more bandwidth, better than PCI-X)
    * Other types of interconnects
        + SCSI bus
        + Peripheral bus
        + Bridges handle differences

Device Drivers

    * Device-specific software components (per each device type)
        + Responsible for device access, management, and control
    * Provided by device manufacturers per OS version
    * Each OS standardizes interfaces
        + Device independence (OS doesn't need to be specialized for a type of
        functionality)
        + Device diversity (OS can support arbitrarily different devices)

| ![drivers](images/drivers.png) |
|:--:|
| Device Drivers |

Types of Devices

    * Block: disk
        + Read/write block of data
        + Direct access to arbitrary block
    * Character: keyboard
        + Get/put character
    * Network devices
        + Stream of data (not a fixed block size)
    * OS representation of a device is a special device file
    * UNIX-like systems
        + /dev
        + tmpfs
        + devfs

CPU/Device Interactions

    * Memory-mapped I/O: Access device registers is equivalent to loading/
    storing in memory
        + Part of 'host' physical memory dedicated for device interactions
        + Base address registers (BAR)
        + Configured during boot process
    * I/O port: Dedicated in/out instructions for device access
        + Target device (I/O port) and value in register
    * Interrupt
        + Pros: Can be generated as soon as possible
        + Cons: Interrupt handling steps
    * Polling
        + When convenient for OS
        + Delay or CPU overhead
    * Interrupt vs polling depends on kind of device and objectives

Device Access: Programmed I/O (PIO)

    * CPU "programs" the device by writing to command registers
        + Controls data movement by accessing data registers
    * No additional hardware support
    * Example: NIC (data is a network packet)
        + Write command to request packet transmission
        + Copy packet to data registers
        + Repeat until packet sent
        + 1500B packet; 8 byte registers/bus
            - 1 (for bus command) + 188 (for data)
            - 189 total CPU store instructions

Device Access: Direct Memory Access (DMA)

    * CPU "programs" the device via command registers
        + Controls data movement via DMA controls
        + DMA controller used for CPU/device communication
    * Example: NIC (data is a network packet)
        + Write command to request packet transmission
        + Configure DMA controller with in-memory address and size of packet 
        buffer
        + 1500B packet; 8 byte registers/bus
            - 1 (for bus command) + 1 (DMA configure)
            - Fewer steps, but DMA configuration is more complex
    * Data buffer must be in physical memory until transfer completes for DMA
        + Must pin regions; not swappable

Typical Device Access

    * Perform system call
    * In-kernel stack
    * Driver invocation
    * Device request configuration
    * Device performs request

| ![deviceaccess](images/device_access.png) |
|:--:|
| Typcial Device Access |

Operating System Bypass

    * OS Bypass: Not required to go through the kernel
        + Device registers/data directly accessible
        + OS configures then gets out of the way
        + "User-level driver" (library)
    * OS still retains coarse-grained control
    * Relies on device features (sufficient registers)
        + Sufficient registers
        + De-multiplex capability for different processes
        + Kernel typically performs these operations, so device must perform

Synchronous vs Aynchronous Access

    * Synchronous I/O operations
        + Process blocks
    * Aynchronous I/O operations
        + Process continues
        + Later...
            - Process checks and retrieves result
            - Process is notified that the operation completed and results are 
            ready

Block Device Stack

    * Processes use files -> Logical storage unit
    * Kernel file system (FS, POSIX API)
        + How to find and access file
        + OS specifies interface
    * Generic block layer
        + OS standardized block interface
        + Allows OS to interact with different interfaces in a uniform way
    * Device driver
    * Device (protocol-specific API)
    
| ![blockdevicestack](images/block_device_stack.png) |
|:--:|
| Block Device Stack |

Virtual File System

    * What if files are on more than one device?
    * What if devices work better with different filesystem implementations?
    * What if files are not on a local device (accessed via network)?
    * Linux implements a virtual filesystem that the user interacts with
        + Each underlying file system must implement a set of file system 
        abstractions
        + Allows the user to interact with different devices in a uniform way

| ![virtualfilesystem](images/virtual_filesystem.png) |
|:--:|
| Virtual Filesystem |

Virtual File System Abstractions

    * Files are the elements on which the VFS operates
    * File descriptor: OS representation of file
        + Open, read, write, sendfile, lock, close, ...
    * inode: Persistent representation of file "index"
        + List of all data blocks
        + Device, permissions, size, ...
    * dentry: directory entry, corresponds to single path component
        + /users/ada -> /, /users, /users/ada
        + Filesystem maintains cache of dentry entries
    * superblock: filesystem-specific information regarding FS layout

Virtual File System on Disk

    * file: Data blocks on disk
    * inode: Track files' blocks
        + Also resides on disk in some block
    * superblock: overall map of disk blocks
        + inode blocks
        + data blocks
        + free blocks

Extended Filesystem v2.0 (ext2)

    * ext2: Second extended filesystem
    * For each block group...
        + Superblock: #inodes, #disk blocks, start of free blocks
        + Group descriptor: bitmaps, #free nodes, #directories
        + bitmaps: tracks free blocks and inodes
        + indoes: 1 to max number, 1 per file
        + data blocks: file data

| ![ext2](images/ext2.png) |
|:--:|
| ext2 Filesystem |

inodes

    * Index of all disk blocks corresponding to a file
        + file: identified by inode
        + inode: list of all blocks + other metadata
    * Pros: Easy to perform sequential or random accesses to the file
    * Cons: Limit on file size (limited by total number of blocks)

| ![inode](images/inode.png) |
|:--:|
| inode |

inodes with Indirect Pointers

    * Can use indirect pointers to solve file size issues
        + Index of all disk blocks corresponding to a file
    * inodes contain...
        + metadata
        + pointers to blocks 
    * Direct pointer: Points to a data block
        + 1 kB per entry
    * Indirect pointer: Points to a block of pointers
        + 256 kB per entry
    * Double Indirect pointer: Points to a pointer to a block of pointers
        + 64 MB per entry
    * Pros: Small inode but large file sizes
    * Cons: File access slowdown (many disk accesses)

Disk Access Optimizations

    * Caching/buffering: Reduce #disk accesses
        + Buffer cache in main memory
        + read/write from cache
        + periodically flush to disk - fsync()
    * I/O scheduling: Reduce disk head movement
        + Maximize sequential vs random access
        + Write block 25, write block 17; If disk head is at 15, schedule 17->25
    * Prefetching: Increases cache hits
        + Leverages locality
        + Read block 17 -> also 18, 19
    * Journaling/logging: Reduce random access (ext3, ext4)
        + "Describe" write in log: block, offset, value
        + Periodically apply updates to proper disk locations
