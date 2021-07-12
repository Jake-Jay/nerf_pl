#!/bin/bash

# Set defaults
EPOCHS=5
ROOT_DIR="/mnt/raid/jpencharz/lego"
STYLE_IMG="./style_images/mondrian.jpg"


# Get args
while getopts e:s: flag
do
    case "${flag}" in
        e) EPOCHS=${OPTARG};;
        s) STYLE_IMG=${OPTARG};;
    esac
done

# Get style name from style image path
# Read the split words into an array based on / delimiter
temp=$STYLE_IMG
IFS='/'
read -a strarr <<< "$temp"
FILE_NAME=${strarr[-1]}
IFS='.'
read -a strarr <<< "$FILE_NAME"
STYLE=${strarr[0]}


echo
echo "Epochs: $EPOCHS";
echo "Style: $STYLE";
echo "Data directory: $ROOT_DIR";
echo "Style image: $STYLE_IMG ";
echo

# Start the pipeline (skip stage 1 for now)
echo '* ['$(date):'] SKIPPING STAGE 1'

# CUDA_VISIBLE_DEVICES=0 python train.py \
#     --root_dir "/mnt/raid/jpencharz/lego" --dataset_name blender \
#     --N_importance 64 --N_samples 64 --noise_std 0 --lr 5e-4 --lr_scheduler cosine \
#     --img_wh 400 400  --num_epochs 20 --exp_name lego_large --stage density

echo '* ['$(date):'] STAGE 2'

# Get density checkpoint
pattern="ckpts/lego_med/{epoch:d}/*"
files=( $pattern )
len_files=${#files[@]}
let len_files--
DENSITY_CKPT=${files[len_files]}
echo "Loading from density checkpoint: ${DENSITY_CKPT}";


# Generate style experiment name
BASE_NAME="lego_med_"
STYLE_EXP_NAME="$BASE_NAME$STYLE"
echo "Style experiment name: $STYLE_EXP_NAME";

# CUDA_VISIBLE_DEVICES=0 python train.py \
#     --root_dir $ROOT_DIR --dataset_name blender \
#     --N_importance 64 --N_samples 64 --noise_std 0  --lr 5e-4 --lr_scheduler cosine \
#     --img_wh 100 100  --num_epochs 20 --exp_name $STYLE_EXP_NAME --stage style \
#     --ckpt_path "$DENSITY_CKPT" --style_img "$STYLE_IMG"
 

echo '* ['$(date):'] EVAL'

# Get styling checkpoint
pattern="ckpts/$STYLE_EXP_NAME/{epoch:d}/*-v1*"
files=( $pattern )
len_files=${#files[@]}
let len_files--
STYLE_CKPT=${files[len_files]}
echo "Loading from style checkpoint: $STYLE_CKPT";

# Generate scene name
BASE_NAME="lego_"
VERSION=""
SCENE_NAME="$BASE_NAME$STYLE$VERSION"
echo "Scene name: $SCENE_NAME";

# CUDA_VISIBLE_DEVICES=0 python eval.py \
#    --root_dir $ROOT_DIR \
#    --dataset_name blender --scene_name $SCENE_NAME \
#    --img_wh 400 400 --N_importance 64 \
#    --ckpt_path "$STYLE_CKPT"







