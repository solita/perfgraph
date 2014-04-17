## What it is

Perfgraph is the visualizer for performance regression data of Jenkins JMeter tests.
Data is gathered by perfdata project. The data is stored in mongodb and visualized with d3.

Currently it is used in KIOS and the dataflow goes like this

Jenkins (JMeter) -> server.coffee (process-builds) -> mongodb -> server.coffee (access data) -> browser (d3)

This project is specialiced to current toolchain and has some hardcoded
parameters in it.

## Status

In production, heavily tailored data retrieval. Production special parsing of troughput data.
Classes under server package have to be tailored to specific data sources and format.

## Setting up the development environment
1. Install and start mongod

2. 
```
git clone https://github.com/solita/perfgraph.git
cd perfgraph
sudo npm install -g grunt-cli grunt-init bower coffee-script
npm install
grunt &
supervisor -w server,server.coffee server.coffee &
open http://localhost:3000
```

## Mongodb

Uses localhost as mongodb host. Uses database "kios-perf".

## Other requirements

For meaningful data some performance measurements builds are needed. The code is tailored to get JMeter
logs from Jenkins server. Example implementation is used internally, so the default urls must be edited
under server/*.coffee

## Who

sirkkalap - Petri Sirkkala, KIOS, Solita

![Screenshot of the radiator](public/img/readme-preview-image.png)

