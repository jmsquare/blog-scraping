# blog-scraping
This repository provides the scrap_blog function which enables to scrap the content of a blog whose URL is organized by date

Scrap_blog function contains 5 smaller functions:
- Get_content_post gives the content of a url containing several blog posts. We use the CSS class DIV to delimitate blog posts
- Get_links returns all the URL links contained in a web page except from "read more" links
- GetLinks_readmore returns all the URL links of type "read more" (CSS class <a>) in a given page
- Get_content_api gives the whole content of a page when the page contains only one blog post
- Create_target_links creates URL links organized by date
