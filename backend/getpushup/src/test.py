import sys

def main():
    if len(sys.argv) != 2:
        print("Error: expecting one argument")
        return
    try:
        value = int(sys.argv[1])
        print(value * 2)
    except ValueError:
        print("Error: invalid number")

if __name__ == "__main__":
    main()