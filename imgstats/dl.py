#! /usr/bin/env python2.7

# This script downloads all the images from the pages listed in site_list.txt

from HTMLParser import HTMLParser
import urllib2
import urllib
import urlparse
import os
import re
import imghdr 

def is_absolute(url):
  return bool(urlparse.urlparse(url).netloc)

def convert_url(url, base_url):
  if url.startswith("//"):
    return "http:" + url
  if is_absolute(url):
    return url
  purl = urlparse.urlparse(base_url)
  if url.startswith('/'):
    return purl.scheme + "://" + purl.netloc + url
  return base_url + url

def get_ext(url):
  path = urlparse.urlparse(url).path
  return os.path.splitext(path)[1]

def is_img(url):
  ext = [".jpg", ".jpeg", ".png", ".gif"]
  return get_ext(url).lower() in ext

class HTMLImgParser(HTMLParser):
  def __init__(self, url):
    HTMLParser.__init__(self)
    self.imgs = set()
    self.url = url

  def handle_starttag(self, tag, attrs):
    if tag == "img":
      for attr in attrs:
        if attr[0] == "src":
          img_url = attr[1]
          if is_img(img_url):
            self.imgs.add(convert_url(img_url, self.url))
          break
    elif tag == "link":
      for attr in attrs:
        if attr[0] == "href":
          if get_ext(attr[1]) == ".css":
            css_url = convert_url(attr[1], self.url)
            folder_url = css_url.rsplit('/', 1)[0] + '/'
            req = urllib2.Request(convert_url(attr[1], self.url))
            css = urllib2.urlopen(req).read()
            for res in re.findall('url\(([^)]+)\)', css):
              if res[0] == "'" or res[0] == '"':
                res = res[1:-1]
              if is_img(res):
                self.imgs.add(convert_url(res, folder_url))

g_counter = 0

def getImgsFromUrl(url):
  global g_counter
  #req = urllib2.Request(url, headers={ 'User-Agent': 'Mozilla/5.0 (Android; Mobile; rv:12.0) Gecko/12.0 Firefox/12.0' })
  req = urllib2.Request(url)
  html = urllib2.urlopen(req).read()
  for f in ["utf8", "cp1252"]:
    try:
      html = html.decode(f)
      break
    except:
      pass

  parser = HTMLImgParser(url)
  parser.feed(html)

  #print parser.imgs
  for img in parser.imgs:
    print img, g_counter
    path = "imgs/" + str(g_counter)
    urllib.urlretrieve(img, "imgs/" + str(g_counter))
    what = imghdr.what(path)
    if what == None:
      print "None:", img
      os.remove(path)
    else:
      os.rename(path, path + '.' + what)
    g_counter += 1

if __name__ == "__main__":
  try:
    os.mkdir("imgs")
  except:
    pass

  f = open("site_list.txt")
  sites = f.readlines()
  f.close()

  for site in sites:
    getImgsFromUrl(site.strip())
