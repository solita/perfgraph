## What it is

Perfgraph is the visualizer for performance regression data of Jenkins JMeter tests.
Data is gathered by perfdata project. The data is stored in mongodb and visualized with d3.

Currently it is used in KIOS and the dataflow goes like this

Jenkins (JMeter) -> server.coffee (process-builds) -> mongodb -> server.coffee (access data) -> browser (d3)

This project is specialiced to current toolchain and has some hardcoded
parameters in it.

## Status

Early development, uses random data in visualization. No database access and data 
aggregation done yet.

## Setting up the development environment

```
sudo npm install -g grunt bower coffee-script
npm install
grunt --config grunt.coffee
open http://localhost:3000
```

## Mongodb

Uses localhost as mongodb host. Uses database "kios-perf".

## Installing components
(OUTDATED SECTION)
```
cd public
bower install jquery
bower ls --map
```
Use the output to update `require.config` in `main.coffee` accordingly.

## Who

sirkkalap - Petri Sirkkala, KIOS, Solita
