#!/bin/bash

# Example script to run DeepRecInfra.
# This allows you to run the neural recommendation models found in models/
# along with the recommendation load generator to measure inference
# tail-latency It does not include the query scheduler which would
# optimize for latency-bounded throughput (inference QPS)

###############################################################################

########## Epoch args ##############
# The total number of inference queries run is product of the number of epochs and number of batches
# Inference querues = nepochs * num_batches
# The number of batches is the unique number of data inputs generated by the data generators
# The number of epochs of epochs determines how many iterations to loop over
# Configuring these parameters is important to getting accurate caching
# behavior based on the use case being modeled
nepochs=512
num_batches=32

epoch_args="--nepochs $nepochs --num_batches $num_batches"

########## Inference engine args ##############

# The number of inference engines determines the unique number of Caffe2
# CPU processes to parallelize queries over
inference_engines=32
caffe2_net_type="async_dag"

engine_args="--inference_engines $inference_engines --caffe2_net_type $caffe2_net_type"

########## Query size args ##############
# Configuration for query sizes.
batch_size_distribution="normal" # number of candidate items in query follows normal distribution
max_mini_batch_size=1024 # maximum number of candidate items queries
avg_mini_batch_size=165 # mean number of canidate items in query
var_mini_batch_size=16 # variation of number of canidate items in query
sub_task_batch_size=64 # per-core query size (number of items processed per-core)

batch_args="--batch_size_distribution $batch_size_distribution --max_mini_batch_size $max_mini_batch_size --avg_mini_batch_size $avg_mini_batch_size --var_mini_batch_size $var_mini_batch_size --sub_task_batch_size $sub_task_batch_size"

########## Accelerator arguments ##############
accel_request_size_thres=165
accel_args="--accel_request_size_thres $accel_request_size_thres --model_accel"

###############################################################################

mkdir -p log/
CWD=$(pwd)
echo $CWD
cd ../../
arrival_rate=5.

python DeepRecSys.py $epoch_args $engine_args $batch_args $accel_args --avg_arrival_rate $arrival_rate --queue --config_file "models/configs/dlrm_rm1.json" > $CWD/log/dlrm_rm1_normal

########### Query size args ##############
# Configuration for query sizes.
batch_size_distribution="lognormal" # number of candidate items in query follows normal distribution
max_mini_batch_size=1024 # maximum number of candidate items queries
avg_mini_batch_size=5.1  # mean number of canidate items in query
var_mini_batch_size=0.2  # variation of number of canidate items in query
sub_task_batch_size=64  # per-core query size (number of items processed per-core)

batch_args="--batch_size_distribution $batch_size_distribution --max_mini_batch_size $max_mini_batch_size --avg_mini_batch_size $avg_mini_batch_size --var_mini_batch_size $var_mini_batch_size --sub_task_batch_size $sub_task_batch_size"

python DeepRecSys.py $epoch_args $engine_args $batch_args $accel_args --avg_arrival_rate $arrival_rate --queue --config_file "models/configs/dlrm_rm1.json" > $CWD/log/dlrm_rm1_lognormal