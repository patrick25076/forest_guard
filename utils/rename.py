import os

def rename_images_labels(folder_path):
    images_folder = os.path.join(folder_path, "images")
    labels_folder = os.path.join(folder_path, "labels")

    # Ensure folders exist
    if not os.path.exists(images_folder) or not os.path.exists(labels_folder):
        print("Images or labels folder not found.")
        return

    # Get a list of all image files in the images folder
    image_files = sorted([f for f in os.listdir(images_folder) if f.endswith(".jpg")])

    # Rename images and labels
    for idx, image_file in enumerate(image_files):
        # Generate new names
        if image_file == '001.jpg':
            print("The files are already renamed")
            return
        
        new_image_name = f"{idx + 1:03d}.jpg"
        new_label_name = f"{idx + 1:03d}.txt"

        # Build file paths
        old_image_path = os.path.join(images_folder, image_file)
        new_image_path = os.path.join(images_folder, new_image_name)

        old_label_path = os.path.join(labels_folder, image_file.replace(".jpg", ".txt"))
        new_label_path = os.path.join(labels_folder, new_label_name)

        # Rename files
        os.rename(old_image_path, new_image_path)
        os.rename(old_label_path, new_label_path)

        print(f"Renamed {image_file} to {new_image_name} and {image_file.replace('.jpg', '.txt')} to {new_label_name}")

if __name__ == "__main__":
    repo_path = "RomaniaChapter_IllegalDeforestation"
    evaluation_folder_path = os.path.join(repo_path, "backend", "src", "evaluation", "License Plate Evaluation System Data" , "test")

    rename_images_labels(evaluation_folder_path)
