shinyUI(fluidPage(
        titlePanel("Data Science Capstone Project - Last Word Prediction"),
        fluidRow(
                column(12,
                       h1("Instruction"),
                       p("Please wait for the panel of the left that says 'Prediction' loads a table with the result for the default text."),
                       p("The loading process take some time if the Shiny App has been down."),
                       h2("Introduction"),
                       p("The original purpose of the project was to develop an N-gram model to predict the next word, given a piece of text."),
                       p("During the 'analysis phase' of the project, it was concluded that a more practical and concrete application to the original objective of 'Predicting the next word' could be achieved by narrowing it down to finer-grained objectives: "),
                       p("1.- Complete the given sentence or paragraph with its last word."),
                       p("2.- Suggest the complete sentence or paragraph that is most likely, given a fragment of text."),
                       p("Based on the evaluation criteria, this application tackles the prediction of the next word considering the case previously described in 1; i.e., the last word in a sentence.")
                )
        ),
        sidebarLayout(
                sidebarPanel(
                        h1('Sentence or Paragraph to complete: '),
                        textInput("inputText", label = NULL,value = "How are you Btw thanks for the RT You gonna be in DC anytime soon Love to see you Been way way too"),
                        
                        h1('Source'),
                        p("Use this section to select the source of the text."),
                        selectInput("sourceIn", "Source:", 
                                    choices = c("Twitter", "News", "All"),
                                    selected = "All"),
                        #sliderInput("weirdness", "How weird the last word is:", 
                        #            min = 2, max = 20, step = 1, value = 5),
                        #h2("Amount of PCA components retained for the Tresh selected:"),
                        #h3("Arm Sensor Components:"),
                        #verbatimTextOutput("armPCAoutput"),
                        width = 6
                ),
                mainPanel(
                    tabsetPanel(
                        tabPanel("Prediction", dataTableOutput("resultTable")),
                        tabPanel("Justification", 
                                 h2("Practical perspective"),
                                 p("In an effort to simplify the scope of the problem, a 'practical' application was considered. In other words, what task is most likely to ease the user's experience whenever prediction of words is required?"),
                                 p("Consider for instance, 'google'. Whenever a user is typing under the 'search box', the auto-complete feature makes a proper suggestion of the next word. In practice, the best bet is to assume that the 'next' word is actually the 'last' word, this significantly reduces the scope of the problem and thus, improves time of response and application performance."),
                                 h2("Theoretical perspective"),
                                 p("N-gram models were originally proposed by Claude Shannon and as a explanatory intuition for his proposal of Communication theory."),
                                 p("In this theory, the communication process is modeled as a Markov Processes that run infenitelly."),
                                 p("In the real case of Natural Language, people does not produce infinite sequences. Instead, people produce emsembles of sequences that are related to each other."),
                                 p("To model this behaviour, the definition of the underlined stochastic process used to model the prediction of the next word was modified from the typical n-gram approach."),
                                 p("The approach used consider a Markov Process that have a Martingale Process associated and the next word to predict is a 'Stopping Time' in the process."),
                                 p("In other words, the approach assume that the underlined process that produce the sequence of words is going to stop after the predicted word.")
                        ),
                        tabPanel("Table", plotOutput("viewHistClusters"))
                    ),
                    width = 6
                )
        )
))