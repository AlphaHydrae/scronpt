# scronpt

> Run an arbitrary [Bash][bash] script on a [cron][cron] schedule.

[![MIT License](https://img.shields.io/static/v1?label=license&message=MIT&color=informational)](https://opensource.org/licenses/MIT)

## Usage

```bash
# Run a script hourly (default schedule)
docker run --rm --init \
       -v "/path/to/your/script:/usr/local/bin/script" \
       ghcr.io/alphahydrae/scronpt

# Run a script every day a quarter past midnight
docker run --rm --init -e "SCRONPT_CRON=15 0 * * *" \
       -v "/path/to/your/script:/usr/local/bin/script" \
       ghcr.io/alphahydrae/scronpt

# Run the default script that says hello, every minute
docker run --rm --init -e "SCRONPT_MINUTE=*" ghcr.io/alphahydrae/scronpt
```

Scronpt will run the arbitrary script you provide on your schedule.

> [!TIP]
> The script runs in a temporary directory that is deleted once your script has
> finished executing, in case you need to work on some files.

## Configuration

| Environment variable       | Default value           | Description                                                                           |
| :------------------------- | :---------------------- | :------------------------------------------------------------------------------------ |
| `$SCRONPT_SCRIPT`          | `/usr/local/bin/script` | The script to run                                                                     |
| `$SCRONPT_MINUTE`          | `0`                     | Minute part of the cron schedule                                                      |
| `$SCRONPT_HOUR`            | `*`                     | Hour part of the cron schedule                                                        |
| `$SCRONPT_DAY`             | `*`                     | Day part of the cron schedule                                                         |
| `$SCRONPT_MONTH`           | `*`                     | Month part of the cron schedule                                                       |
| `$SCRONPT_DAY_OF_THE_WEEK` | `*`                     | Day of the week part of the cron schedule                                             |
| `$SCRONPT_CRON`            | `0 * * * *`             | The cron schedule to run the script on (built from the previous variables by default) |
| `$SCRONPT_UID`             | -                       | UID of the `scronpt` user that will run the script                                    |
| `$SCRONPT_GID`             | -                       | GID of the `scronpt` group of the user that will run the script                       |

## Exit codes

Scronpt will exit with the following codes when known errors occur:

| Code | Description                              |
| :--- | :--------------------------------------- |
| 1    | An unexpected error occurred.            |
| 10   | The script to execute cannot be found.   |
| 11   | The script to execute is not executable. |

[bash]: https://www.gnu.org/software/bash/
[cron]: https://en.wikipedia.org/wiki/Cron
