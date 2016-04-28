library(shiny)
library(tm)
library(R.utils)
library(stringr)

#load("ReleaseTwitter.RData")
#load("ReleaseNews.RData")
load("ReleaseAll.RData")

library(caret)
set.seed(32343)

library(ggplot2)


shinyServer(function(input, output) {
        inputTextReactive <- reactive({
            s <- switch(input$sourceIn,
                        "Twitter" = 1,
                        "News" = 2,
                        "All" = 3)
            text <- input$inputText
            text <- removeNumbers(text)
            text <- removePunctuation(text)
            text <- stripWhitespace(text)
            text <- str_trim(text)
            text <- str_to_lower(text)
            words <- strsplit(text," ",fixed = TRUE)
            words <- unlist(words)
            tokens <- c()
            if(length(words)>5){
                words <- c(words[1:3], words[(length(words)-1):length(words)])
            }
            if(length(words)>0){
                for(i in (1:length(words))){
                    w <- words[i]
                    # get the index of the word in our vocabulary dictionary
                    wIndex <- vocabullarySimplifiedByWord[[w]]  
                    if(!is.null(wIndex)){
                        tokens <- c(tokens, wIndex)
                    }
                }
            }
            tokensCopy <- tokens
            lC <- NULL
            retries <- 0
            while(is.null(lC)){
                if(length(tokens)>4){
                    pI <- paste0(tokens[1],"_",tokens[2],"_",tokens[3],"_",tokens[4],"_",tokens[5])
                    if(s==1)
                        lC <- lastGramFreqEnUsTwitterList[[pI]]  
                    else if(s==2)
                        lC <- lastGramFreqEnUsNewsList[[pI]]  
                    else{
                        lC <- lastGramFreqEnUsTwitterList[[pI]]  
                        if(is.null(lC))
                            lC <- lastGramFreqEnUsNewsList[[pI]]  
                        else
                            lC <- c(lC, lastGramFreqEnUsNewsList[[pI]])
                    }
                }
                else if(length(tokens)==4){
                    pI <- paste0(tokens[1],"_",tokens[2],"_",tokens[3],"_",tokens[4])
                    if(s==1)
                        lC <- fiveGramFreqEnUsTwitterList[[pI]]  
                    else if(s==2)
                        lC <- fiveGramFreqEnUsNewsList[[pI]]  
                    else{
                        lC <- fiveGramFreqEnUsTwitterList[[pI]]  
                        if(is.null(lC))
                            lC <- fiveGramFreqEnUsNewsList[[pI]]  
                        else
                            lC <- c(lC, fiveGramFreqEnUsNewsList[[pI]])
                    }
                }
                else if(length(tokens)==3){
                    pI <- paste0(tokens[1],"_",tokens[2],"_",tokens[3])
                    if(s==1)
                        lC <- fourGramFreqEnUsTwitterList[[pI]]  
                    else if(s==2)
                        lC <- fourGramFreqEnUsNewsList[[pI]]  
                    else{
                        lC <- fourGramFreqEnUsTwitterList[[pI]]  
                        if(is.null(lC))
                            lC <- fourGramFreqEnUsNewsList[[pI]]  
                        else
                            lC <- c(lC, fourGramFreqEnUsNewsList[[pI]])
                    }
                }
                else if(length(tokens)==2){
                    pI <- paste0(tokens[1],"_",tokens[2])
                    if(s==1)
                        lC <- triFreqEnUsTwitterList[[pI]]  
                    else if(s==2)
                        lC <- triGramFreqEnUsNewsList[[pI]]  
                    else{
                        lC <- triGramFreqEnUsTwitterList[[pI]]  
                        if(is.null(lC))
                            lC <- triGramFreqEnUsNewsList[[pI]]  
                        else
                            lC <- c(lC, triGramFreqEnUsNewsList[[pI]])
                    }
                }
                else if(length(tokens)==1){
                    pI <- paste0(tokens[1])
                    if(s==1)
                        lC <- biGramFreqEnUsTwitterList[[pI]]  
                    else if(s==2)
                        lC <- biGramFreqEnUsNewsList[[pI]]  
                    else{
                        lC <- biGramFreqEnUsTwitterList[[pI]]  
                        if(is.null(lC))
                            lC <- biGramFreqEnUsNewsList[[pI]]  
                        else{
                            lC <- c(lC, biGramFreqEnUsNewsList[[pI]])
                            lC <- unique(lC)
                        }
                    }
                }
                if(is.null(lC)){
                    if(length(tokens)>1){
                        if(retries==0)
                            tokens <- tokens[2:length(tokens)]
                        else
                            tokens <- tokens[1:length(tokens)-1]
                    }
                    else{
                        retries <- retries + 1
                        if(retries==0)
                            tokens <- tokensCopy
                        else if(retries==1)
                            break
                    }
                }
            }
            resultWord <- c()
            resultChance <- c()
            if(!is.null(lC)){
                for(w in lC){
                    wordCanI <- paste0(pI,"_",w)
                    resultWord <- c(resultWord, vocabullarySimplifiedByIndex[w])
                    if(length(tokens)>4){
                        if(s==1)
                            resultChance <- c(resultChance, lastGramFreqEnUsTwitter[[wordCanI]])
                        else if(s==2)
                            resultChance <- c(resultChance, lastGramFreqEnUsNews[[wordCanI]])
                        else{
                            tCha1 <- lastGramFreqEnUsTwitter[[wordCanI]]
                            tCha2 <- lastGramFreqEnUsNews[[wordCanI]]
                            if(is.null(tCha1))
                                tCha <- tCha2
                            else if(is.null(tCha2))
                                tCha <- tCha1
                            else
                                tCha <- tCha1 + tCha2
                            resultChance <- c(resultChance, tCha)
                        }
                    }
                    else if(length(tokens)==4){
                        if(s==1)
                            resultChance <- c(resultChance, fiveGramFreqEnUsTwitter[[wordCanI]])
                        else if(s==2)
                            resultChance <- c(resultChance, fiveGramFreqEnUsNews[[wordCanI]])
                        else{
                            tCha1 <- fiveGramFreqEnUsTwitter[[wordCanI]]
                            tCha2 <- fiveGramFreqEnUsNews[[wordCanI]]
                            if(is.null(tCha1))
                                tCha <- tCha2
                            else if(is.null(tCha2))
                                tCha <- tCha1
                            else
                                tCha <- tCha1 + tCha2
                            resultChance <- c(resultChance, tCha)
                        }
                    }
                    else if(length(tokens)==3){
                        if(s==1)
                            resultChance <- c(resultChance, fourGramFreqEnUsTwitter[[wordCanI]])
                        else if(s==2)
                            resultChance <- c(resultChance, fourGramFreqEnUsNews[[wordCanI]])
                        else{
                            tCha1 <- fourGramFreqEnUsTwitter[[wordCanI]]
                            tCha2 <- fourGramFreqEnUsNews[[wordCanI]]
                            if(is.null(tCha1))
                                tCha <- tCha2
                            else if(is.null(tCha2))
                                tCha <- tCha1
                            else
                                tCha <- tCha1 + tCha2
                            resultChance <- c(resultChance, tCha)
                        }
                    }
                    else if(length(tokens)==2){
                        if(s==1)
                            resultChance <- c(resultChance, triGramFreqEnUsTwitter[[wordCanI]])
                        else if(s==2)
                            resultChance <- c(resultChance, triGramFreqEnUsNews[[wordCanI]])
                        else{
                            tCha1 <- triGramFreqEnUsTwitter[[wordCanI]]
                            tCha2 <- triGramFreqEnUsNews[[wordCanI]]
                            if(is.null(tCha1))
                                tCha <- tCha2
                            else if(is.null(tCha2))
                                tCha <- tCha1
                            else
                                tCha <- tCha1 + tCha2
                            resultChance <- c(resultChance, tCha)
                        }
                    }
                    else if(length(tokens)==1){
                        if(s==1)
                            resultChance <- c(resultChance, biGramFreqEnUsTwitter[[wordCanI]])
                        else if(s==2)
                            resultChance <- c(resultChance, biGramFreqEnUsNews[[wordCanI]])
                        else{
                            tCha1 <- biGramFreqEnUsTwitter[[wordCanI]]
                            tCha2 <- biGramFreqEnUsNews[[wordCanI]]
                            if(is.null(tCha1))
                                tCha <- tCha2
                            else if(is.null(tCha2))
                                tCha <- tCha1
                            else
                                tCha <- tCha1 + tCha2
                            resultChance <- c(resultChance, tCha)
                        }
                    }
                }
            }
            else{
                if(length(tokens)==0)
                    cIn <- 1
                else
                    cIn <- length(tokensCopy)
                wIs <- vocabullarySimplifiedFreqByIndexAndPosOrder[1:50,cIn]
                resultWord <- vocabullarySimplifiedByIndex[wIs]
                resultChance <- vocabullarySimplifiedFreqByIndexAndPos[wIs,length(tokensCopy)]
            }
            totalChance <- sum(resultChance)
            resultOrder <- order(resultChance, decreasing = TRUE)
            resultChance <- resultChance/totalChance
            result <- data.frame(resultOrder, resultWord[resultOrder], resultChance[resultOrder])
            names(result) <- c("Rank", "Word", "Probability")
            result
        })
        

        output$resultTable <- renderDataTable(inputTextReactive())
        
        
        output$viewHistClusters <- renderPlot({
                qplot(Probability, 
                      data = inputTextReactive(), 
                      binwidth = 2, main = paste0("Frequency in ", input$sourceIn," Source"))
        })

        #output$armPCAoutput <- renderText({
        #        pcaReactive()
        #        paste0(preProcArm$numComp, " components of 12 original dimensions.")
        #        })
})


