library(shiny)
library(tm)
library(R.utils)
library(stringr)

load("ReleaseTwitter.RData")
load("ReleaseNews.RData")

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
            #text <- str_to_lower(text)
            words <- strsplit(text," ",fixed = TRUE)
            words <- unlist(words)
            tokens <- c()
            if(length(words)>5){
                words <- c(words[1:3], words[(length(words)-1):length(words)])
            }
            for(w in words){
                # get the index of the word in our vocabulary dictionary
                wIndex <- vocabularyHCcorporaEnUSbyWord[[w]]  
                if(is.null(wIndex)){
                    tokens <- c(tokens, "*")
                }
                else{
                    tokens <- c(tokens, wIndex)
                }
            }
            if(length(tokens)<5){
                wAd <- rep("*",5-length(tokens))
                if(length(tokens)<3){
                    tokens <- c(wAd, tokens)
                }
                else{
                    tokens <- c(tokens[1], wAd, tokens[2:length(tokens)])
                }
            }
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
            if(is.null(lC)){
                pI <- paste0("*","_","*","_","*","_","*","_","*")
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
            resultWord <- c()
            resultChance <- c()
            for(w in lC){
                wordCanI <- paste0(pI,"_",w)
                resultWord <- c(resultWord, vocabularyHCcorporaEnUSbyIndex[w])
                if(s==1)
                    resultChance <- c(resultChance, lastGramFreqEnUsTwitter[[wordCanI]])
                else if(s==2)
                    resultChance <- c(resultChance, lastGramFreqEnUsNews[[wordCanI]])
                else{
                    resultChance <- c(resultChance, lastGramFreqEnUsTwitter[[wordCanI]])
                    resultChance <- c(resultChance, lastGramFreqEnUsNews[[wordCanI]])
                }
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


