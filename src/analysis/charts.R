library(ggplot2)
library(tidyr)
library(dplyr)
library(scales)
library(forcats)
library(showtext)
# font_add_google("Roboto", "Roboto")
# showtext_auto()

# Directories and file names
data_dir <- '../data/analysis/'
denials_file <- 'denials.csv'
company_year_file <- 'company_year.csv'
charts_dir <- '../assets/charts/'

# Load data
denials <- read.csv(paste0(data_dir, denials_file))
company_year <- read.csv(paste0(data_dir, company_year_file))

# Format dataframe field names
format_field_names <- function(df) {
  new_names <- gsub('\\.', '_', tolower(names(df)))
  return(new_names)
}
names(denials) <- format_field_names(denials)
names(company_year) <- format_field_names(company_year)

# Create custom themes
line_chart_theme <- theme(
  , text = element_text(family = 'Arial')
  , panel.background = element_blank()
  , panel.grid.minor.y = element_blank()
  , panel.grid.major.x = element_blank()
  , panel.grid.minor.x = element_blank()
  , panel.grid.major.y = element_line(color = 'gray90', size = .3)
  , axis.ticks.y = element_blank()
  , axis.ticks.x = element_line(size = .4, color = 'black')
  , axis.ticks.length = unit(0.2, "cm")
  , axis.line.x = element_blank()
  , legend.title = element_blank()
  , plot.title = element_text(face = 'bold', size = 12)
  , plot.subtitle = element_text(face = 'italic', size = 10, margin = margin(b = 20))
  , plot.caption = element_text(color = 'gray30', hjust = 0)
  , legend.key.width = unit(1, "cm")
  )

# Chart: Denial rates by industry
## Format data
plotdata_denials <- denials %>% 
  select(
    fiscal_year
    , denial_rate___outsourcing
    , denial_rate___tech
    , denial_rate___other
  ) %>% 
  pivot_longer(-fiscal_year, names_to = 'industry', values_to = 'denial_rate') %>% 
  mutate(
    industry = gsub('denial_rate___', '', industry)
    , industry = factor(industry
                        , levels = c('other', 'outsourcing', 'tech')
                        , labels = c('Other', 'Outsourcing', 'Big Tech')
    )
  )

## Create chart
ggplot(plotdata_denials) +
  labs(
    title = 'H-1B Visa Denial Rates'
    , subtitle = 'Share of applications rejected by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  ) +
  line_chart_theme +
  geom_line(
    aes(fiscal_year, denial_rate, color = industry)
    , size = 1
  ) +
  scale_y_continuous(
    labels = label_percent()
    , expand = c(0, 0)
    , limits = c(0, 0.25)
    , breaks = seq(0.05, 0.25, by = 0.05)
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plotdata_denials$fiscal_year)
      , max(plotdata_denials$fiscal_year)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  geom_segment(
    aes(x = min(fiscal_year), xend = max(fiscal_year), y = 0, yend = 0)
    , inherit.aes = FALSE
    , color = "black"
    , size = .4
  ) +
  scale_color_manual(
    values = c(
      'Outsourcing' = '#F5921B'
      , 'Big Tech' = '#5E40BE'
      , 'Other' = 'gray80'
    )
    , breaks = c('Outsourcing', 'Big Tech', 'Other')
  )


# Chart: Denial rates for outsourcing companies
## Format data
plotdata_denials_outsourcing <- denials %>% 
  select(
    fiscal_year
    , initial_denial_rate___outsourcing
    , continuing_denial_rate___outsourcing
  ) %>% 
  pivot_longer(-fiscal_year, names_to = 'visa_type', values_to = 'denial_rate') %>% 
  mutate(
    visa_type = gsub('_denial_rate___outsourcing', '', visa_type)
    , visa_type = factor(visa_type
                         , levels = c('initial', 'continuing')
                         , labels = c('New Visas', 'Renewals')
    )
  )

## Create chart
ggplot(plotdata_denials_outsourcing) +
  labs(
    title = 'H-1B Visa Denial Rates for Outsourcing Companies'
    , subtitle = 'Share of applications rejected by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  ) +
  line_chart_theme +
  geom_line(
    aes(fiscal_year, denial_rate, color = visa_type, linetype = visa_type)
    , size = 1
  ) +
  scale_y_continuous(
    labels = label_percent()
    , expand = c(0, 0)
    , limits = c(0, 0.40)
    , breaks = seq(0.10, 0.40, by = 0.10)
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plotdata_denials$fiscal_year)
      , max(plotdata_denials$fiscal_year)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  geom_segment(
    aes(x = min(fiscal_year), xend = max(fiscal_year), y = 0, yend = 0)
    , inherit.aes = FALSE
    , color = "black"
    , size = .4
  ) +
  scale_color_manual(
    values = c(
      'New Visas' = '#F5921B'
      , 'Renewals' = '#F5921B'
    )
    , breaks = c('New Visas', 'Renewals')
  ) +
  scale_linetype_manual(
    values = c(
      "New Visas" = "solid"
      , "Renewals" = "dashed"
    ))

# svglite::svglite("/Users/nikhilgahlawat/Desktop/test_chart_svglite.svg", width = 6, height = 3.3)
# print(test_plot)
# dev.off()

# Chart: Outsourcing company approvals
## List of companies to display
outsourcing_company_list <- c(
  'Cognizant Technology Solutions'
  , 'Infosys'
  , 'Tata Consultancy Services'
  , 'Wipro'
  , 'Accenture'
  , 'IBM'
)

## Format chart data
plotdata_approvals_outsourcing <- company_year %>% 
  filter(employer %in% outsourcing_company_list) %>% 
  select(employer, fiscal_year, initial_approval, continuing_approval, total_approval, share_of_cap) %>% 
  # Create a field that ranks companies by total approvals
  # Will use later to determine how companies are ordered in the chart
  left_join(
    company_year %>% 
      filter(employer %in% outsourcing_company_list) %>% 
      group_by(employer) %>% 
      summarise(total_approval = sum(total_approval)) %>% 
      mutate(approvals_rank = rank(total_approval)) %>% 
      select(-total_approval)
  ) %>% 
  mutate(
    employer = case_when(
      employer == 'Cognizant Technology Solutions' ~ 'Cognizant'
      , employer == 'Tata Consultancy Services' ~ 'Tata'
      , TRUE ~ employer
      )
    , employer = fct_reorder(employer, approvals_rank, .desc = TRUE)
  )

## Create chart
ggplot(plotdata_approvals_outsourcing) +
  labs(
    title = 'H-1B Visa Approvals: Outsourcing Companies'
    , subtitle = 'New visas and renewals approved by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  ) +
  line_chart_theme +
  geom_line(
    aes(fiscal_year, total_approval, color = employer, linetype = employer)
    , size = 1
  ) +
  geom_segment(
    aes(x = min(fiscal_year), xend = max(fiscal_year), y = 0, yend = 0)
    , inherit.aes = FALSE
    , color = "black"
    , size = .4
  ) +
  scale_y_continuous(
    # labels = label_number(scale_cut = cut_short_scale())
    labels = label_comma()
    , expand = c(0, 0)
    , limits = c(0, 30e3)
    , breaks = seq(10e3, 30e3, by = 10e3)
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plotdata_approvals_outsourcing$fiscal_year)
      , max(plotdata_approvals_outsourcing$fiscal_year)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  scale_color_manual(
    values = c(
      'Cognizant' = '#F8AE54'
      , 'Infosys' = '#CA6C0F'
      , 'Tata' = '#732E00'
      , 'Wipro' = '#F8AE54'
      , 'Accenture' = '#CA6C0F'
      , 'IBM' = '#732E00'
    )
  ) +
  scale_linetype_manual(
    values = c(
      'Cognizant' = 'solid'
      , 'Infosys' = 'solid'
      , 'Tata' = 'solid'
      , 'Wipro' = 'dashed'
      , 'Accenture' = 'dashed'
      , 'IBM' = 'dashed'
      )
    )







# Chart: Tech company approvals
## List of companies to display
tech_company_list <- c(
  'Amazon'
  , 'Microsoft'
  , 'Alphabet (Google)'
  , 'Apple'
  , 'Intel'
  , 'Meta Platforms (Facebook)'
)

## Format chart data
plotdata_approvals_tech <- company_year %>% 
  filter(employer %in% tech_company_list) %>% 
  select(employer, fiscal_year, initial_approval, continuing_approval, total_approval, share_of_cap) %>% 
  # Create a field that ranks companies by total approvals
  # Will use later to determine how companies are ordered in the chart
  left_join(
    company_year %>% 
      filter(employer %in% tech_company_list) %>% 
      group_by(employer) %>% 
      summarise(total_approval = sum(total_approval)) %>% 
      mutate(approvals_rank = rank(total_approval)) %>% 
      select(-total_approval)
  ) %>% 
  mutate(
    employer = case_when(
      employer == 'Meta Platforms (Facebook)' ~ 'Meta'
      , employer == 'Alphabet (Google)' ~ 'Google'
      , TRUE ~ employer
    )
    , employer = fct_reorder(employer, approvals_rank, .desc = TRUE)
  )

## Create chart
ggplot(plotdata_approvals_tech) +
  labs(
    title = 'H-1B Visa Approvals: Tech Companies'
    , subtitle = 'New visas and renewals approved by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  ) +
  line_chart_theme +
  geom_line(
    aes(fiscal_year, total_approval, color = employer, linetype = employer)
    , size = 1
  ) +
  geom_segment(
    aes(x = min(fiscal_year), xend = max(fiscal_year), y = 0, yend = 0)
    , inherit.aes = FALSE
    , color = "black"
    , size = .4
  ) +
  scale_y_continuous(
    # labels = label_number(scale_cut = cut_short_scale())
    labels = label_comma()
    , expand = c(0, 0)
    , limits = c(0, 30e3)
    , breaks = seq(10e3, 30e3, by = 10e3)
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plotdata_approvals_outsourcing$fiscal_year)
      , max(plotdata_approvals_outsourcing$fiscal_year)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  scale_color_manual(
    values = c(
      'Amazon' = '#B6A6E9'
      , 'Microsoft' = '#5E40BE'
      , 'Google' = '#21134D'
      , 'Apple' = '#B6A6E9'
      , 'Intel' = '#5E40BE'
      , 'Meta' = '#21134D'
    )
  ) +
  scale_linetype_manual(
    values = c(
      'Amazon' = 'solid'
      , 'Microsoft' = 'solid'
      , 'Google' = 'solid'
      , 'Apple' = 'dashed'
      , 'Intel' = 'dashed'
      , 'Meta' = 'dashed'
    )
  )
