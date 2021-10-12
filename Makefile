MD=markdown
PDF=pdf

all: introduction processes threads pthreads thread_design thread_performance scheduling

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
