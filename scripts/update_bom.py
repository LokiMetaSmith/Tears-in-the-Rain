import csv

def csv_to_markdown_table(csv_filepath, md_filepath):
    try:
        with open(csv_filepath, 'r', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            rows = list(reader)

        if not rows:
            print(f"Warning: {csv_filepath} is empty.")
            return

        header = rows[0]
        data = rows[1:]

        markdown_lines = []

        # Header row
        markdown_lines.append("| " + " | ".join(header) + " |")

        # Separator row
        markdown_lines.append("| " + " | ".join(["---"] * len(header)) + " |")

        # Data rows
        for row in data:
            # Handle potential None values or missing columns
            safe_row = [str(cell) if cell is not None else "" for cell in row]
            markdown_lines.append("| " + " | ".join(safe_row) + " |")

        with open(md_filepath, 'w', encoding='utf-8') as mdfile:
            mdfile.write("# Bill of Materials\n\n")
            mdfile.write("\n".join(markdown_lines))
            mdfile.write("\n")

        print(f"Successfully converted {csv_filepath} to {md_filepath}")

    except FileNotFoundError:
        print(f"Error: File not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    csv_to_markdown_table('bom.csv', 'bom.md')
