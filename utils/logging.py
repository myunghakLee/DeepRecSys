import json
import sys

def save_log(args, file_name, dload_time, total_time, nbatches):
    write_data = {}

    write_data['file_name'] = file_name
    file_name = f"log/{file_name}_{'gpu' if args.use_accel else 'cpu'}_b{args.num_batches}.json"
    f = open(file_name, "w")
    write_data["args"] = vars(args)
    write_data["Total_data_loading_time"] = dload_time
    write_data["Total_data_loading_time_per_iter"] = dload_time / (args.nepochs * nbatches)
    write_data["Total_computation_time"] = (total_time - dload_time)
    write_data["Total_computation_time_per_iter"] = (total_time - dload_time) / (args.nepochs * nbatches)
    write_data["Total_execution_time"] = total_time
    write_data["Total_execution_time_per_iter"] = total_time / (args.nepochs * nbatches)
    import json
    with open(file_name, "w") as f:
        json.dump(write_data, f, indent = 4)
