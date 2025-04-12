library(ggplot2)
library(tidyr)
library(dplyr)
library(scales)
library(showtext)
# font_add_google("Roboto", "Roboto")
# showtext_auto()

# Directories and file names
data_dir <- '../data/analysis/'
denials_file <- 'denials.csv'

# Load data
denials <- read.csv(paste0(data_dir, denials_file))

# Format field names
names(denials) <- gsub('\\.', '_', tolower(names(denials)))

# Chart: Denial rates by industry
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
plotdata_denials

ggplot(plotdata_denials) +
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
  ) +
  theme(
    , text = element_text(family = 'Arial')
    , panel.background = element_blank()
    , panel.grid.minor.y = element_blank()
    , panel.grid.major.x = element_blank()
    , panel.grid.minor.x = element_blank()
    , panel.grid.major.y = element_line(color = 'gray90', size = .3)
    , axis.ticks.y = element_blank() #element_line(color = 'gray90')
    , axis.ticks.x = element_line(size = .4, color = 'black')
    , axis.ticks.length = unit(0.2, "cm")
    , axis.line.x = element_blank()
    , legend.title = element_blank()
    , plot.title = element_text(face = 'bold', size = 12)
    , plot.subtitle = element_text(face = 'italic', size = 10, margin = margin(b = 20))
    , plot.caption = element_text(color = 'gray30', hjust = 0)
  ) +
  labs(
    title = 'H-1B Visa Denial Rates'
    , subtitle = 'Share of applications rejected by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  )


# Chart: Denial rates for outsourcing companies
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
plotdata_denials_outsourcing

ggplot(plotdata_denials_outsourcing) +
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
    )) +
  theme(
    , text = element_text(family = 'Arial')
    , panel.background = element_blank()
    , panel.grid.minor.y = element_blank()
    , panel.grid.major.x = element_blank()
    , panel.grid.minor.x = element_blank()
    , panel.grid.major.y = element_line(color = 'gray90', size = .3)
    , axis.ticks.y = element_blank() #element_line(color = 'gray90')
    , axis.ticks.x = element_line(size = .4, color = 'black')
    , axis.ticks.length = unit(0.2, "cm")
    , axis.line.x = element_blank()
    , legend.title = element_blank()
    , plot.title = element_text(face = 'bold', size = 12)
    , plot.subtitle = element_text(face = 'italic', size = 10, margin = margin(b = 20))
    , plot.caption = element_text(color = 'gray30', hjust = 0)
    , legend.key.width = unit(1, "cm")
  ) +
  labs(
    title = 'H-1B Visa Denial Rates for Outsourcing Companies'
    , subtitle = 'Share of applications rejected by the USCIS'
    , caption = 'Source: USCIS. Industry classification described in methodology.'
    , x = ''
    , y = ''
  )


# svglite::svglite("/Users/nikhilgahlawat/Desktop/test_chart_svglite.svg", width = 6, height = 3.3)
# print(test_plot)
# dev.off()


