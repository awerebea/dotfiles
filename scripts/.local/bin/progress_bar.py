import shutil
import sys


def print_progress_bar(part_num, parts_total, elem_num=None, elems_total=None):
    terminal_width = shutil.get_terminal_size((100, 20)).columns
    # Check if total progress information is provided
    if elem_num is not None and elems_total is not None:
        if part_num != 1:
            # Move the cursor up to the beginning of the first line
            sys.stdout.write("\033[F")
            sys.stdout.flush()
        # Calculate dynamic length for the total progress bar
        total_info_len = len(str(elems_total)) * 2 + 16  # ' xx/yy (zzz.zz%)'
        # Calculate total progress bar length
        total_bar_len = min(100, terminal_width) - total_info_len
        total_progress = int(total_bar_len * elem_num / elems_total)
        total_remaining = total_bar_len - total_progress
        # Format the total counter part
        elems_total_str_len = len(str(elems_total))
        total_counter_str = (
            f"{elem_num:>{elems_total_str_len}}/{elems_total:<{elems_total_str_len}}"
        )
        # Format the total percentage part without extra leading space
        total_percentage_str = f"{(elem_num / elems_total * 100):.2f}%"
        # Format the total progress bar
        total_progress_bar = (
            f"[{total_progress * '#'}{'-' * total_remaining}]"
            + f" {total_counter_str} ({total_percentage_str:>7})"
        )
        # Print the total progress bar on the first line
        sys.stdout.write(total_progress_bar + "\n")
    else:
        sys.stdout.write("\r")

    # Calculate dynamic length for the progress bar
    info_len = len(str(parts_total)) * 2 + 16  # ' xx/yy (zzz.zz%)'
    # Calculate progress bar length
    bar_len = min(100, terminal_width) - info_len
    progress = int(bar_len * part_num / parts_total)
    remaining = bar_len - progress
    # Format the counter part
    parts_total_str_len = len(str(parts_total))
    counter_str = (
        f"{part_num:>{parts_total_str_len}}/{parts_total:<{parts_total_str_len}}"
    )
    # Format the percentage part without extra leading space
    percentage_str = f"{(part_num / parts_total * 100):.2f}%"
    # Format the progress bar for the current element
    progress_bar = (
        f"[{progress * '#'}{'-' * remaining}] {counter_str} ({percentage_str:>7})"
    )

    # Print the progress bar for the current element on the second line
    sys.stdout.write("\r" + progress_bar)
    sys.stdout.flush()
    if part_num == parts_total:
        time.sleep(1)
        sys.stdout.write("\r" + " " * terminal_width + "\r")
        sys.stdout.flush()
        if elem_num is None or elems_total is None:
            sys.stdout.write("\033[F")
        else:
            if elem_num == elems_total:
                sys.stdout.write("\033[F" + "\r" + " " * terminal_width + "\r")
            else:
                sys.stdout.write("\033[F")
            sys.stdout.flush()


if __name__ == "__main__":
    import time

    # Example usage in a nested loop
    total_elements = 5
    total_parts = 25

    print("Progress bar example: Start")
    for part in range(1, total_parts + 1):
        print_progress_bar(part, total_parts)
        time.sleep(0.05)
    print()
    print("Progress bar example: Finish")

    print("Multiple elements progress bar example: Start")
    for elem in range(1, total_elements + 1):
        for part in range(1, total_parts + 1):
            print_progress_bar(
                part,
                total_parts,
                elem_num=elem,
                elems_total=total_elements,
            )
            time.sleep(0.05)
    print("Multiple elements progress bar example: Finish")
