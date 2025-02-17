# trace performance of a thread

## create the trace file 

```bash
sudo perf record -g --call-graph dwarf -p <pid of the process getopts trace>
perf script | gzip > perf.script.gz # run in the same server
```

##  create flamegraph 

Download [FlameGraph](https://github.com/brendangregg/FlameGraph)

```bash
zcat perf.script.gz | perl stackcollapse-perf.pl | perl flamegraph.pl > output.html
```
