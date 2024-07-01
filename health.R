# Load necessary libraries
library(shiny)     # For creating Shiny web applications
library(ggplot2)   # For creating visualizations
library(dplyr)     # For data manipulation
library(DT)        # For displaying tables

# Generate a sample dataset
set.seed(123)  # Set seed for reproducibility
health_data <- data.frame(  # Create a data frame with random health data
  PatientID = 1:100,  # Patient IDs from 1 to 100
  Age = sample(20:80, 100, replace = TRUE),  # Random ages between 20 and 80
  Gender = sample(c("Male", "Female"), 100, replace = TRUE),  # Random genders
  BMI = round(runif(100, 18, 35), 1),  # Random BMI values between 18 and 35
  BloodPressure = round(runif(100, 110, 180), 0),  # Random blood pressure values between 110 and 180
  Cholesterol = round(runif(100, 150, 250), 0)  # Random cholesterol values between 150 and 250
)

# Save the dataset to a CSV file
write.csv(health_data, "health_data.csv", row.names = FALSE)

# Create a Shiny app that reads the dataset, performs some basic analysis, and visualizes it
ui <- fluidPage(  # Define the UI layout
  titlePanel("Health Data Analysis"),  # Title of the app
  sidebarLayout(  # Layout with a sidebar and main panel
    sidebarPanel(  # Sidebar panel for inputs
      selectInput("variable", "Select a variable to visualize:",  # Dropdown to select a variable
                  choices = c("Age", "BMI", "BloodPressure", "Cholesterol")),
      radioButtons("gender", "Select Gender:",  # Radio buttons to select gender
                   choices = c("Both", "Male", "Female"))
    ),
    mainPanel(  # Main panel for outputs
      plotOutput("histogram"),  # Output for histogram
      tableOutput("summary")  # Output for summary statistics table
    )
  )
)

server <- function(input, output) {  # Define server logic
  
  # Read the dataset
  health_data <- read.csv("health_data.csv")
  
  # Reactive expression to filter data based on gender
  filtered_data <- reactive({
    if (input$gender == "Both") {  # If "Both" is selected, use all data
      health_data
    } else {  # Otherwise, filter data by the selected gender
      health_data %>% filter(Gender == input$gender)
    }
  })
  
  # Generate histogram
  output$histogram <- renderPlot({
    ggplot(filtered_data(), aes_string(input$variable)) +  # Create a ggplot with the selected variable
      geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +  # Add histogram layer
      labs(title = paste("Distribution of", input$variable),  # Add title
           x = input$variable,  # X-axis label
           y = "Frequency")  # Y-axis label
  })
  
  # Generate summary statistics
  output$summary <- renderTable({
    filtered_data() %>%  # Use filtered data
      summarise(
        Mean = mean(get(input$variable)),  # Calculate mean
        Median = median(get(input$variable)),  # Calculate median
        SD = sd(get(input$variable)),  # Calculate standard deviation
        Min = min(get(input$variable)),  # Calculate minimum value
        Max = max(get(input$variable))  # Calculate maximum value
      )
  })
}

# Run the Shiny app
shinyApp(ui, server)
