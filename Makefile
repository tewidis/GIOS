MD=markdown
PDF=pdf

all: introduction processes threads pthreads thread_design thread_performance scheduling memory_management interprocess_communication synchronization_constructs io_management virtualization remote_procedure_calls distributed_file_systems distributed_shared_memory datacenter_technologies

clean:
	rm -f *~
	rm -f $(PDF)/*
	rm -f $(MD)/*~

introduction: $(MD)/introduction.md
	pandoc -V geometry:margin=1in -o $(PDF)/introduction.pdf $(MD)/introduction.md

processes: $(MD)/process_and_process_management.md
	pandoc -V geometry:margin=1in -o $(PDF)/process_and_process_management.pdf $(MD)/process_and_process_management.md

threads: $(MD)/threads_and_concurrency.md
	pandoc -V geometry:margin=1in -o $(PDF)/threads_and_concurrency.pdf $(MD)/threads_and_concurrency.md

pthreads: $(MD)/pthreads.md
	pandoc -V geometry:margin=1in -o $(PDF)/pthreads.pdf $(MD)/pthreads.md

thread_design: $(MD)/thread_design_considerations.md
	pandoc -V geometry:margin=1in -o $(PDF)/thread_design_considerations.pdf $(MD)/thread_design_considerations.md
	
thread_performance: $(MD)/thread_performance_considerations.md
	pandoc -V geometry:margin=1in -o $(PDF)/thread_performance_considerations.pdf $(MD)/thread_performance_considerations.md

scheduling: $(MD)/scheduling.md
	pandoc -V geometry:margin=1in -o $(PDF)/scheduling.pdf $(MD)/scheduling.md

memory_management: $(MD)/memory_management.md
	pandoc -V geometry:margin=1in -o $(PDF)/memory_management.pdf $(MD)/memory_management.md
	
interprocess_communication: $(MD)/inter-process_communication.md
	pandoc -V geometry:margin=1in -o $(PDF)/inter-process_communication.pdf $(MD)/inter-process_communication.md

synchronization_constructs: $(MD)/synchronization_constructs.md
	pandoc -V geometry:margin=1in -o $(PDF)/synchronization_constructs.pdf $(MD)/synchronization_constructs.md

io_management: $(MD)/io_management.md
	pandoc -V geometry:margin=1in -o $(PDF)/io_management.pdf $(MD)/io_management.md

virtualization: $(MD)/virtualization.md
	pandoc -V geometry:margin=1in -o $(PDF)/virtualization.pdf $(MD)/virtualization.md

remote_procedure_calls: $(MD)/remote_procedure_calls.md
	pandoc -V geometry:margin=1in -o $(PDF)/remote_procedure_calls.pdf $(MD)/remote_procedure_calls.md

distributed_file_systems: $(MD)/distributed_file_systems.md
	pandoc -V geometry:margin=1in -o $(PDF)/distributed_file_systems.pdf $(MD)/distributed_file_systems.md

distributed_shared_memory: $(MD)/distributed_shared_memory.md
	pandoc -V geometry:margin=1in -o $(PDF)/distributed_shared_memory.pdf $(MD)/distributed_shared_memory.md

datacenter_technologies: $(MD)/datacenter_technologies.md
	pandoc -V geometry:margin=1in -o $(PDF)/datacenter_technologies.pdf $(MD)/datacenter_technologies.md
