library(ggplot2)
library(tidyr)
library(dplyr)
library(scales)
library(forcats)
library(showtext)
library(svglite)
# font_add_google("Roboto", "Roboto")
# showtext_auto()

# ---- Script setup ----
## Directories and file names
data_dir <- '../data/analysis/'
charts_dir <- '../assets/charts/'
denials_file <- 'denials.csv'
company_year_file <- 'company_year.csv'
wages_file <- 'wages.csv'

## Other constants
axis_linewidth = .5
oranges <- c('#F8AE54', '#F5921B', '#CA6C0F', '#9E4A06', '#732E00')
purples <- c('#B6A6E9', '#876FD4', '#5E40BE', '#3D2785', '#21134D')

# ---- Helper functions ----
## Save charts to disk
save_chart <- function(plot = last_plot(), filename, format = 'png', width = 6, height = 3.3, dpi = 300) {
  format <- tolower(format)
  filepath <- paste0(charts_dir, filename, '.', format)
  if (!format %in% c('png', 'svg')) {
    stop("Unsupported file format. Use 'png' or 'svg'.")
  }
  
  ggsave (
    filename = filepath
    , plot = plot
    , device = format
    , width = width
    , height = height
    , dpi = if(format == 'svg') 0 else dpi
  )
  
  message('Saved plot to: ', filepath)
}

# Custom ggplot themes
line_chart_theme <- theme(
  , text = element_text(family = 'Arial')
  , panel.background = element_blank()
  , panel.grid.minor.y = element_blank()
  , panel.grid.major.x = element_blank()
  , panel.grid.minor.x = element_blank()
  , panel.grid.major.y = element_line(color = 'gray90', linewidth = .3)
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


# ---- Data processing ----
## Load data
denials <- read.csv(paste0(data_dir, denials_file))
company_year <- read.csv(paste0(data_dir, company_year_file))
wages <- read.csv(paste0(data_dir, wages_file))

## Format dataframe field names
format_field_names <- function(df) {
  new_names <- gsub('\\.', '_', tolower(names(df)))
  return(new_names)
}
names(denials) <- format_field_names(denials)
names(company_year) <- format_field_names(company_year)


# ---- Chart: Denial rates by industry ----
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
    , linewidth = 1
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
    , linewidth = axis_linewidth
  ) +
  scale_color_manual(
    values = c(
      'Outsourcing' = oranges[2]
      , 'Big Tech' = purples[3]
      , 'Other' = 'gray80'
    )
    , breaks = c('Outsourcing', 'Big Tech', 'Other')
  )

## Save chart
save_chart(filename = 'industry_denial_rates', format = 'png')
save_chart(filename = 'industry_denial_rates', format = 'svg')

# ---- Chart: Denial rates for outsourcing companies ----
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
    , linewidth = 1
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
    , linewidth = axis_linewidth
  ) +
  scale_color_manual(
    values = c(
      'New Visas' = oranges[2]
      , 'Renewals' = oranges[2]
    )
    , breaks = c('New Visas', 'Renewals')
  ) +
  scale_linetype_manual(
    values = c(
      "New Visas" = "solid"
      , "Renewals" = "dashed"
    ))

## Save chart
save_chart(filename = 'outsourcing_denial_rates', format = 'png')
save_chart(filename = 'outsourcing_denial_rates', format = 'svg')


# ---- Chart: Outsourcing company approvals ----
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
    , size = axis_linewidth
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
      'Cognizant' = oranges[1]
      , 'Infosys' = oranges[3]
      , 'Tata' = oranges[5]
      , 'Wipro' = oranges[1]
      , 'Accenture' = oranges[3]
      , 'IBM' = oranges[5]
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

## Save chart
save_chart(filename = 'outsourcing_approvals', format = 'png')
save_chart(filename = 'outsourcing_approvals', format = 'svg')

# ---- Chart: Tech company approvals ----
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
    , size = axis_linewidth
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
      min(plotdata_approvals_tech$fiscal_year)
      , max(plotdata_approvals_tech$fiscal_year)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  scale_color_manual(
    values = c(
      'Amazon' = purples[1]
      , 'Microsoft' = purples[3]
      , 'Google' = purples[5]
      , 'Apple' = purples[1]
      , 'Intel' = purples[3]
      , 'Meta' = purples[5]
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

## Save chart
save_chart(filename = 'tech_approvals', format = 'png')
save_chart(filename = 'tech_approvals', format = 'svg')


# ---- Chart: Wages by industry ----
plotdata_wages <- wages %>% 
  mutate(
    category = paste(group, PW_WAGE_LEVEL)
    ) %>% 
  filter(group %in% c('Outsourcing', 'Tech')) %>% 
  filter(PW_WAGE_LEVEL %in% c('Level I', 'Level IV'))

plotdata_wage_ribbons <- plotdata_wages %>% 
  filter(PW_WAGE_LEVEL %in% c('Level I', 'Level IV')) %>% 
  mutate(
    PW_WAGE_LEVEL = gsub('\\s', '_', tolower(PW_WAGE_LEVEL))
  ) %>% 
  select(DATAFILE_YEAR, group, PW_WAGE_LEVEL, WAGE_ANNUAL_FROM) %>% 
  pivot_wider(
    id_cols = c('DATAFILE_YEAR', 'group')
    , names_from = 'PW_WAGE_LEVEL'
    , values_from = 'WAGE_ANNUAL_FROM'
  )

ggplot(plotdata_wages) + 
  labs(
    title = 'Wages for H-1B Workers'
    , subtitle = 'Typical wage ranges for H-1B workers at outsourcing and tech companies'
    , caption = 'Source: Department of Labor. Ranges are based on the prevailing wage levels designated by the DOL.'
    , x = ''
    , y = ''
  ) +
  line_chart_theme +
  geom_ribbon(
    data = plotdata_wage_ribbons %>% filter(group == 'Outsourcing')
    , aes(x = DATAFILE_YEAR, ymin = level_i, ymax = level_iv)
    , fill = oranges[2]
    , alpha = .1
  ) +
  geom_ribbon(
    data = plotdata_wage_ribbons %>% filter(group == 'Tech')
    , aes(x = DATAFILE_YEAR, ymin = level_i, ymax = level_iv)
    , fill = purples[3]
    , alpha = .3
  ) +
  geom_line(
    aes(DATAFILE_YEAR, WAGE_ANNUAL_FROM, group = category, color = group)
    # , linetype = 'dashed'
    , size = .5
  ) +
  geom_segment(
    aes(
      x = min(DATAFILE_YEAR)
      , xend = max(DATAFILE_YEAR)
      , y = plotdata_wage_ribbons %>% filter(DATAFILE_YEAR == 2015 & group == 'Outsourcing') %>% pull(level_iv)
      , yend = plotdata_wage_ribbons %>% filter(DATAFILE_YEAR == 2015 & group == 'Outsourcing') %>% pull(level_iv)
    )
    , color = oranges[2]
    , size = .5
    , linetype = 'dotted'
  ) +
  geom_segment(
    aes(
      x = min(DATAFILE_YEAR)
      , xend = max(DATAFILE_YEAR)
      , y = plotdata_wage_ribbons %>% filter(DATAFILE_YEAR == 2015 & group == 'Tech') %>% pull(level_iv)
      , yend = plotdata_wage_ribbons %>% filter(DATAFILE_YEAR == 2015 & group == 'Tech') %>% pull(level_iv)
    )
    , color = purples[3]
    , size = .5
    , linetype = 'dotted'
  ) +
  geom_segment(
    aes(x = min(DATAFILE_YEAR), xend = max(DATAFILE_YEAR), y = 0, yend = 0)
    , inherit.aes = FALSE
    , color = "black"
    , size = axis_linewidth
  ) +
  scale_y_continuous(
    # labels = label_comma(prefix = '$')
    labels = label_number(scale_cut = cut_short_scale(), prefix = '$')
    , expand = c(0, 0)
    , limits = c(0, 200e3)
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plotdata_wages$DATAFILE_YEAR)
      , max(plotdata_wages$DATAFILE_YEAR)
      , by = 2
    )
    , expand = c(0,0)
  ) +
  scale_color_manual(
    values = c(
      'Outsourcing' = oranges[2]
      , 'Tech' = purples[3]
    )
  ) +
  # Make room on the side of the chart for annotations
  theme(
    # legend.position = 'top'
    # , legend.box.margin = margin(0, 0, -10, 0)
    # , plot.subtitle = element_text(margin = margin(b = 0))
    # , plot.margin = margin(5.5, 110, 5.5, 5.5)
  )

## Save chart
save_chart(filename = 'industry_wages', format = 'png')
save_chart(filename = 'industry_wages', format = 'svg')

