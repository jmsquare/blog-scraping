#######################################################
#Blog Scraping when URL is organized by date
#########################################################

require(lubridate)
require(plyr)
require(stringr)
require(XML)
require(RCurl)
require(jsonlite)
require(httr)
##################################################################################################
target_links<-url


#####################################################################
#Get_content_post gives the content of a url containing several blog posts. We use the CSS class DIV to delimitate blog posts
#############################################################################
get_content_post <- function (url,selector='post-body entry-content'){  
  raw <- getURL(url,encoding="UTF-8", ssl.verifypeer = FALSE)
  PARSED <- htmlParse(url) #Format the html code d
  selector_CSS<- paste( "//div[@class=" , selector , "]" ,sep="")
  xpathSApply(PARSED, selector_CSS ,xmlValue)

}


########################################################################
#Get_links returns all the URL links contained in a web page except from "read more" links
########################################################################
getLinks <- function(url,pattern){ 
  raw <- getURL(url,encoding="UTF-8")
  PARSED <- htmlParse(raw) #Format the html code d
  links<-unique(xpathSApply(PARSED,"//a/@href"))
  which<-str_detect(getLinks(url), paste(url,pattern,sep=""))
  return (links[which])
}


########################################################################
#GetLinks_readmore returns all the URL links of type "read more" (CSS class <a>) in a given page
########################################################################
getLinks_readmore <- function(url,selector_more="more-link"){  
  raw <- getURL(url,encoding="UTF-8")
  PARSED <- htmlParse(raw) #Format the html code d
  selector_CSS<-paste("//a[@class='",selector_more, "']/@href",sep="")
  links<-unique(xpathSApply(PARSED,selector_CSS))
  return (links)
}

#######################################
##Get_content_api gives the whole content of a page when the page contains only one blog post
#############################################
get_content_api <- function (url){ 
api_juicer <- 'http://juicer.herokuapp.com/api/article?url='
target <- paste(api_juicer,url,sep="")
raw.data <- readLines(target, warn="F") #en JSON
rd <- fromJSON(raw.data)
return(rd$article$body)
#dat <-data.frame(dat)
}


###############################################
#Create_target_links creates URL links organized by date
##############################################"
create_target_links <- function (url,begin_year,end_year){
target_links<-NULL

for (year in begin_year : end_year){
  	#From January to September
  	for (month in 1:9){
    	target_link<-paste(url,year,paste("0",month,sep=""),"",sep="/")
    	target_links<-c(target_links,target_link)   
  	}
	#From October to December
  	for (month in 10:12){
	target_link<-paste(url,year,month,sep="/")
    	target_links<-c(target_links,target_link)   
  	}
}
return (target_links)
}

contents<-NULL #A elnver

######################################################
#INPUTS
#################################################
begin_year<-2010
end_year<-2015
url<-"http://www.lescheveuxdemini.com"

######################################################
##Scrap_blog scraps the content of blogs using previous functions
########################################################
scrap_blog <- function(
, url
, direct = TRUE
, read_more = FALSE
, link_pattern = TRUE
, begin_year=2012
, end_year=2015
, pattern_link = "2014"
, selector_post='post-body entry-content'
, selector_more_read="more-link"){

targets <- create_target_links (url,begin_year,end_year)
for (target in targets){

if (read_more){
entire_post_links<-getLinks_readmore(target,selector_more=selector_more_read) 
vector_content<- apply(as.matrix(entire_post_links), 1, function(x){content = get_content_api(x)} ) 
link_date <- rep.int (target, length(entire_post_links) ) 
df <- as.data.frame (cbind(link_date , vector_content) ) 
}


if (link_pattern){
entire_post_links<-getLinks(target,pattern=paste(target,pattern_link,sep="")) 
vector_content<- apply(as.matrix(entire_post_links), 1, function(x){content = get_content_api(x)} ) 
link_date <- rep.int (target, length(entire_post_links) ) 
df <- as.data.frame (cbind(link_date , vector_content) ) 
}

if (direct){
vector_content<-get_content_post(target,selector=selector_post)
link_date <- rep.int (target, length(entire_post_links) ) 
df <- as.data.frame (cbind(link_date , vector_content) ) 
}

else {
df <- data.frame(link_date= character(0)),vector_content =character(0) )
}

} #end of for loop

}#end of scrap_blog function


