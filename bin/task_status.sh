#!/usr/bin/env bash

kapacitor $1 $(kapacitor list tasks | awk '{if(NR>1)print}' | awk '{print $1}')
