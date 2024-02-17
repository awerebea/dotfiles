import shutil
import sys


def print_progress_bar(current_num, total_num):
    # Get terminal width, with a default of 100 if not available
    window_width = shutil.get_terminal_size((100, 20)).columns

    # Calculate dynamic length for the progress bar
    length_dynamic = len(str(total_num)) * 2 + 16  # ' xx/yy (zzz.zz%)'

    # Calculate progress bar length
    bar_length = min(100, window_width) - length_dynamic
    progress = int(bar_length * current_num / total_num)
    remaining = bar_length - progress

    # Format the counter part
    counter_format = f"{{:>{len(str(total_num))}}}/{{:<{len(str(total_num))}}}"
    counter_str = counter_format.format(current_num, total_num)

    # Format the percentage part without extra leading space
    percentage_str = f"{(current_num / total_num * 100):.2f}%"

    # Format and print the progress bar
    progress_bar = (
        f'[{progress * "#"}{"-" * remaining}] {counter_str} ({percentage_str:>7})'
    )
    sys.stdout.write("\r" + progress_bar)
    sys.stdout.flush()


if __name__ == "__main__":
    import time

    # Example usage in a loop
    total_iterations = 72
    for i in range(1, total_iterations + 1):
        print_progress_bar(i, total_iterations)
        time.sleep(0.1)

    # Print a newline after the loop to avoid overwriting the progress bar
    print()
