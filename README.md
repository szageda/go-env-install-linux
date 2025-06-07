# Go Programming Toolchain Installation Script for Linux

This is a semi-automated script for installing and updating the basic Go programming tools for Linux systems.

**Supported Platforms and Architectures**

- Linux amd64

**Supported Shells**

- Bash

**Supported Installation Paths**

By default, `go-toolchain-install.sh` supports the Go recommended installation directory (`/usr/local/go`) for a system-wide configuration. But you also have the option to choose a local installation for the current user only (`~/.local/share/go`).

`go-toolchain-update.sh` is able to update the Go toolchain in different directories; however, if you installed it using root or `sudo` to a directory other than `/usr/local/go`, the update may fail. To circumvent this, run the script as root or with `sudo`.

## Installation

1. Clone the repository to your computer.

```shell
git clone https://github.com/szageda/go-toolchain-install-linux.git
```

2. Navigate into the cloned directory.

```shell
cd go-toolchain-install-linux
```

3. Make the scripts executable.

```shell
chmod +x *.sh
```

4. Run the script of your choice:

    - If you want to install the Go programming tools:

    ```shell
    ./go-env-install.sh
    ```
    - If you want update the already installed Go programming tools:

    ```shell
    ./go-env-update.sh
    ```

## License

MIT license – refer to `LICENSE` in the root directory.

**Disclaimer:**  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
