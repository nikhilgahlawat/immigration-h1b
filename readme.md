# H-1B Visa Data
This project cleans and analyzes data around the H-1B visa program.

See [DOL](https://www.dol.gov/agencies/whd/immigration/h1b) and [USCIS](https://www.uscis.gov/working-in-the-united-states/h-1b-specialty-occupations) website for a more detailed overview of the H-1B visa.

## Data Sources
### U.S. Citizenship and Immigration Services
The [USCIS Employer Data Hub](https://www.uscis.gov/tools/reports-and-studies/h-1b-employer-data-hub) contains data on the employers that have submitted petitions to hire H-1B nonimmigrant workers. It shows the number of petitions submitted, approved, and denied by each employer in a given fiscal year as well as other fields. More documentation available [here](https://www.uscis.gov/tools/reports-and-studies/h-1b-employer-data-hub/understanding-our-h-1b-employer-data-hub).

### Department of Labor
The DOL's [Foreign Labor Certification Perfomance Data](https://www.dol.gov/agencies/eta/foreign-labor/performance) page contains data on Labor Certification Application forms that employers are required to submit prior to applying for H-1B visas. The data contains information such as the number of H-1B visas the employer intends to submit applications for, the intended wage, the job title, and more.

### CompaniesMarketCap
[CompaniesMarketCap](https://companiesmarketcap.com/) compiles company-level data, including SEC filings. This data is used to categorize employers in the USCIS and DOL data into industry groups.

## Data Processing
Scripts to download and clean up the USCIS and DOL data are found in the `/src/data_processing/` directory. The run order for the scripts are:

USCIS:
1. `uscis_raw_data`
2. `uscis_analysis_file`

DOL:
1. `lca_raw_data_pre_2020`
2. `lca_raw_data_2020_onward`
3. `lca_dedupe`
4. `lca_standardize_employer_name`
5. `lca_dedupe`
6. `lca_analysis_file`

Scripts are in Jupyter notebooks to make it easier for anyone to adapt them to their own use cases and troubleshoot.

## Analysis
Analysis scripts are found in the `/src/analysis/` directory.

