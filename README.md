Designing a Processor

- Add pipline stages (Each stage on file & add register that store data to stage file)

- Add memory

To run add alias in .bashrc & call pac:
alias pac="iverilog -o result.res processor.v -g2005-sv && vvp result.res;"

