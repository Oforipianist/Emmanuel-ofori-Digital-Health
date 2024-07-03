# Load necessary libraries
if (!require("shiny")) install.packages("shiny", dependencies = TRUE)
if (!require("ggplot2")) install.packages("ggplot2", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)

library(shiny)
library(ggplot2)
library(dplyr)

# Generate a sample dataset
set.seed(123)
health_data <- data.frame(
  PatientID = 1:100,
  Age = sample(20:80, 100, replace = TRUE),
  Gender = sample(c("Male", "Female"), 100, replace = TRUE),
  BMI = round(runif(100, 18, 35), 1),
  BloodPressure = round(runif(100, 110, 180), 0),
  Cholesterol = round(runif(100, 150, 250), 0)
)

# Save the dataset to a CSV file
write.csv(health_data, "health_data.csv", row.names = FALSE)

# Define the User Interface (UI)
ui <- fluidPage(
  titlePanel("Health Data Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Select a variable to visualize:",
                  choices = c("Age", "BMI", "BloodPressure", "Cholesterol")),
      radioButtons("gender", "Select Gender:",
                   choices = c("Both", "Male", "Female"))
    ),
    mainPanel(
      plotOutput("histogram"),
      tableOutput("summary")
    )
  )
)

# Define the Server logic
server <- function(input, output) {
  
  # Read the dataset
  health_data <- read.csv("health_data.csv")
  
  # Reactive expression to filter data based on gender
  filtered_data <- reactive({
    if (input$gender == "Both") {
      health_data
    } else {
      health_data %>% filter(Gender == input$gender)
    }
  })
  
  # Generate histogram
  output$histogram <- renderPlot({
    ggplot(filtered_data(), aes_string(input$variable)) +
      geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
      labs(title = paste("Distribution of", input$variable),
           x = input$variable,
           y = "Frequency")
  })
  
  # Generate summary statistics
  output$summary <- renderTable({
    filtered_data() %>%
      summarise(
        Mean = mean(get(input$variable)),
        Median = median(get(input$variable)),
        SD = sd(get(input$variable)),
        Min = min(get(input$variable)),
        Max = max(get(input$variable))
      )
  })
}

# Run the Shiny app
shinyApp(ui, server)
