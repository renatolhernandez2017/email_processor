module PdfClassMapper
  PDF_CLASSES = {}.tap do |hash|
    {
      Pdfs::MonthlyReport => %w[monthly_report monthly_summary],
      Pdfs::PatientListing => %w[patient_listing save_patient_listing],
      Pdfs::SummaryPatientListing => %w[summary_patient_listing saves_summary_patient_listing],
      Pdfs::UnaccumulatedAddresses => %w[unaccumulated_addresses address_report],
      Pdfs::Tags => %w[tags],
      Pdfs::DepositsInBanks => %w[deposits_in_banks],
      Pdfs::PrintAllStores => %w[print_all_stores]
    }.each do |klass, keys|
      keys.each { |key| hash[key] = klass }
    end
  end.freeze
end
