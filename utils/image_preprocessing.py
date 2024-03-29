import os
import cv2
import numpy as np


def preprocess_and_visualize(image_path, output_folder, steps_to_apply=('standardize_normalize', 'resize'), **kwargs):
    """
    This function preprocesses an image with specified steps and visualizes the original and processed images.

    Parameters:
    - image_path (str): Path to the input image.
    - output_folder (str): Path to the folder where preprocessed images will be saved.
    - steps_to_apply (tuple): Tuple of strings specifying which steps to apply. Default is ('standardize_normalize', 'resize').
    - **kwargs: Additional keyword arguments. For example, target_size=(height, width) for resizing the image.

    Returns:
    None
    """
    # Read original image
    original_image = cv2.imread(image_path)

    # Convert image to 8-bit depth
    original_image = cv2.convertScaleAbs(original_image)

    # Initialize processed_image with a copy of the original image
    processed_image = original_image.copy()

    # Apply selected preprocessing steps
    for step in steps_to_apply:
        if step == 'standardize_normalize':
            # Step 1: Pixel Standardization and Normalization
            processed_image = (processed_image - np.mean(processed_image)) / np.std(processed_image)
            processed_image = (processed_image - np.min(processed_image)) / (
                    np.max(processed_image) - np.min(processed_image))
            print('Step 1: Pixel Standardization and Normalization applied.')

        elif step == 'resize':
            # Step 2: Resize Images to a Standard Size
            target_size = kwargs.get('target_size', (416, 416))
            processed_image = cv2.resize(processed_image, target_size)
            print(f'Step 2: Resize Images to a {target_size} applied.')

        # Add more processing steps if needed

    # Display original image
    cv2.imshow('Original Image', original_image)
    cv2.waitKey(500)  # Adjust the delay time (in milliseconds) as needed

    # Display processed image
    cv2.imshow('Processed Image', processed_image)
    cv2.waitKey(500)

    # Convert processed image data type to uint8 before saving
    processed_image_uint8 = (processed_image * 255).astype(np.uint8)

    # Save preprocessed image
    output_path = os.path.join(output_folder, os.path.basename(image_path))
    cv2.imwrite(output_path, processed_image_uint8)
    print(f'Preprocessed image saved to output folder.')
    cv2.destroyAllWindows()

image_path = "/path_to_image/image.jpg"
output_folder_path = "/output_folder_path"
# Example usage:
preprocess_and_visualize(image_path, output_folder_path, target_size=(224, 224))

