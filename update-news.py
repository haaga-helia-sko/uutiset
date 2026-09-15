#!/usr/bin/env python3
import html
import json
import re
import sys
from html.parser import HTMLParser
from urllib.parse import urljoin

SOURCE_URL = "https://yle.fi/t/18-209712/fi"
MAX_NEWS = 10

def is_article_url(value):
    return value.startswith("/a/") or value.startswith("https://yle.fi/a/")

class ArticleParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.current_href = None
        self.current_text = []
        self.heading_depth = None
        self.articles = []

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        href = attributes.get("href", "")
        if tag in ("h2", "h3"):
            self.heading_depth = tag
            self.current_text = []
            self.current_href = href if is_article_url(href) else None
        elif tag == "a" and self.heading_depth:
            self.current_href = href if is_article_url(href) else self.current_href

    def handle_data(self, data):
        if self.heading_depth:
            self.current_text.append(data)

    def handle_endtag(self, tag):
        if tag == self.heading_depth:
            title = re.sub(r"\s+", " ", html.unescape("".join(self.current_text))).strip()
            if self.current_href and title:
                self.articles.append({
                    "title": title,
                    "description": "Ylen Ammattikorkeakoulut-aiheen uutinen",
                    "date": "",
                    "url": urljoin(SOURCE_URL, self.current_href),
                })
            self.heading_depth = None
            self.current_href = None
            self.current_text = []

html_text = sys.stdin.read()
parser = ArticleParser()
parser.feed(html_text)
unique = []
seen = set()
for article in parser.articles:
    if article["url"] not in seen:
        seen.add(article["url"])
        unique.append(article)
print(json.dumps(unique[:MAX_NEWS], ensure_ascii=False, indent=2))
