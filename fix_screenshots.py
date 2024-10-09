"""Simple script to fix screenshot paths in the static HTML.

Problem:
we're getting 'src="Screenshots/org_screenshot_20240913-153812.png"'
instead of 'src="/Screenshots/org_screenshot_20240913-153812.png"' in the HTML.

Solution:
Replace all instances of 'Screenshots/' with '/Screenshots/'
"""
from pathlib import Path


def get_html_dir() -> Path:
    env_file = Path(__file__).parent / "settings.env"
    for line in env_file.read_text().splitlines():
        try:
            key, value = line.strip().split('=', 1)
        except ValueError:
            continue
        if key == 'HTML_DIR':
            return Path(value)

    raise ValueError("HTML_DIR not found in settings.env")


if __name__ == '__main__':
    # load the HTML dir from settings.env
    html_dir = get_html_dir()

    for file in html_dir.glob('**/*.html'):
        print(f"Fixing {file}")
        content = file.read_text().replace('src="Screenshots/', 'src="/Screenshots/')
        file.write_text(content)

    print("Done")
