#!/bin/bash
set -x

function main {

  init_params "$@"
  run_benchmark

}

# init params
function init_params {
  iters=100
  batch_size=16
  tuned_checkpoint=saved_results
  echo ${max_eval_samples}
  for var in "$@"
  do
    case $var in
      --topology=*)
          topology=$(echo $var |cut -f2 -d=)
      ;;
      --dataset_location=*)
          dataset_location=$(echo $var |cut -f2 -d=)
      ;;
      --input_model=*)
          input_model=$(echo $var |cut -f2 -d=)
      ;;
      --mode=*)
          mode=$(echo $var |cut -f2 -d=)
      ;;
      --batch_size=*)
          batch_size=$(echo $var |cut -f2 -d=)
      ;;
      --iters=*)
          iters=$(echo ${var} |cut -f2 -d=)
      ;;
      --optimized=*)
          optimized=$(echo ${var} |cut -f2 -d=)
      ;;
      --config=*)
          tuned_checkpoint=$(echo $var |cut -f2 -d=)
      ;;
      *)
          echo "Error: No such parameter: ${var}"
          exit 1
      ;;
    esac
  done

}


# run_benchmark
function run_benchmark {
    extra_cmd=''

    if [[ ${mode} == "accuracy" ]]; then
        mode_cmd=" --accuracy "
    elif [[ ${mode} == "performance" ]]; then
        mode_cmd=" --performance --iters "${iters}
    else
        echo "Error: No such mode: ${mode}"
        exit 1
    fi
    if [[ ${optimized} == "true" ]]; then
        extra_cmd=$extra_cmd" --optimized"
    fi
    echo $extra_cmd


    echo $extra_cmd

    if [ "${topology}" = "resnet18_pt2e_static" ]; then
        model_name_or_path="resnet18"
    fi

    if [[ ${mode} == "accuracy" ]]; then
        python main.py \
                --pretrained \
                -a resnet18 \
                -b ${batch_size} \
                --tuned_checkpoint ${tuned_checkpoint} \
                ${dataset_location} \
                ${extra_cmd} \
                ${mode_cmd}
    elif [[ ${mode} == "performance" ]]; then
        incbench --num_cores_per_instance 4 \
                main.py \
                --pretrained \
                -a resnet18 \
                -b ${batch_size} \
                --tuned_checkpoint ${tuned_checkpoint} \
                ${dataset_location} \
                ${extra_cmd} \
                ${mode_cmd}
    else
        echo "Error: No such mode: ${mode}"
        exit 1
    fi
}

main "$@"
