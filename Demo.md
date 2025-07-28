## How to Run the Demo

1. **Install Erlang**

   - Debian/Ubuntu: `sudo apt install erlang`
   - Arch: `sudo pacman -S erlang`
   - macOS: `brew install erlang`
   - Windows: [erlang.org/downloads](https://www.erlang.org/downloads)

2. **Download the project from Github**
   - Unzip it
   - Open it
   
4. **Compile**
   ```bash
   mkdir -p bin
   erlc src/*.erl -o bin

5. **Run**
    ```bash
    erl
    ### in the erlang shell
    app:start().
