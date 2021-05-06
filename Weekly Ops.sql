SELECT o.order_id,
       o.for_review,
       o.chargeback_received,
       o.visa_country,
       o.visa_category,
       o.arrival_date,
       o.total_refunded_usd,
       oi.status,
       oi.created_at,
       oi.closed_at,
       oi.processing_speed,
       oi.processing_deadline,
       oi.queued_until,
       oi.deadline_missed,
       ot.mins,
       oi.qty,
       oi.type,
       o.order_type,
       oi.closed_by_system,
       CASE WHEN oi.closed_at IS NULL AND o.arrival_date < CURRENT_DATE() THEN 1 ELSE 0 END AS is_expired,

       WEEKOFYEAR(CASE WHEN oi.closed_at IS NULL THEN oi.processing_deadline
                     WHEN WEEKOFYEAR(oi.closed_at) < WEEKOFYEAR(CURRENT_DATE())-12 OR WEEKOFYEAR(oi.closed_at) > WEEKOFYEAR(CURRENT_DATE())-1 THEN oi.processing_deadline
                     ELSE oi.closed_at END) AS week_year,
       CASE WHEN oi.closed_at IS NOT NULL THEN "not_queued"

            WHEN oi.queued_until IS NULL THEN "not_queued" ELSE "queued" END AS queued_not_closed,
       CASE WHEN oi.status = "rejected_by_gov" OR oi.status = "cancelled" THEN "cancelled" ELSE "not_cancelled" END AS rejected_canceled,
       CASE WHEN oi.status = "complete" THEN "completed" ELSE "not_completed" END AS completed,
       CASE WHEN oi.deadline_missed IS FALSE THEN "on_time" ELSE "deadline_missed" END AS on_time,
       CASE WHEN o.total_refunded_usd = 0 THEN "not_refunded" ELSE "refunded" END AS refunded,
       CASE WHEN oi.queued_until IS NULL THEN "not_queued" ELSE "queued" END AS queued,
       #flags
CASE
WHEN o.order_type = 'visa' AND oi.type != 'visa' THEN 'addon'
ELSE 'product'
END AS addon_flag,

#Graph counters
CASE WHEN oi.status = "complete" THEN 1 ELSE 0 END AS completed_count,
CASE WHEN oi.status = "incomplete" THEN 1 ELSE 0 END AS incompleted_count,
CASE WHEN o.total_refunded_usd = 0 THEN 0 ELSE 1 END AS refunded_count,
CASE WHEN oi.status ="rejected_by_gov" THEN 1 ELSE 0 END AS rejected_count,
CASE WHEN oi.status = "cancelled" THEN 1 ELSE 0 END AS cancelled_count,
CASE WHEN oi.status = "cancelled" THEN 1 WHEN oi.status = "rejected_by_gov" THEN 1 WHEN o.total_refunded_usd != 0 THEN 1 ELSE 0 END AS unhappy_count,
CASE WHEN oi.deadline_missed IS TRUE THEN 1 ELSE 0 END AS deadline_missed_count,
CASE WHEN oi.deadline_missed IS FALSE AND oi.status = "complete" THEN 1 ELSE 0 END AS on_time_count,
CASE WHEN oi.deadline_missed IS FALSE THEN 0 ELSE 1 END AS not_on_time_count,
CASE WHEN oi.status = "incomplete" THEN "incompleted" ELSE "not_incompleted" END AS incompleted,
CASE WHEN oi.status ="info_needed" THEN 1 ELSE 0 END AS info_needed_count,
CASE WHEN oi.status ="received" THEN 1 ELSE 0 END AS received_count,
CASE WHEN oi.status ="waiting_on_gov" THEN 1 ELSE 0 END AS wog_count,
CASE WHEN oi.status ="reviewed" THEN 1 ELSE 0 END AS reviewed_count,
CASE WHEN oi.status ="complete" THEN 0 ELSE 1 END AS not_complete_count,
CASE WHEN oi.closed_at IS NOT NULL THEN 1 WHEN oi.queued_until IS NULL THEN 1 ELSE 0 END AS not_queued_nc_count,
CASE WHEN oi.closed_at IS NOT NULL THEN 0 WHEN oi.queued_until IS NULL THEN 0 ELSE 1 END AS queued_nc_count,
CASE WHEN oi.type = "visa" THEN 1 ELSE 0 END AS Visa,
CASE WHEN oi.type = "health_declaration" THEN 1 ELSE 0 END AS Health_Declaration,
       #product category
       CASE
       WHEN oi.type = 'passport_photo' THEN 'Photo'
       WHEN oi.type = 'embassy_reg' THEN 'Emb_reg'
       WHEN oi.visa_category LIKE '%Tourist Card%' THEN 'Arrival Card'
       WHEN oi.visa_category LIKE '%Arrival Card%' THEN 'Arrival Card'
       WHEN oi.visa_category LIKE '%Mexico Electronic Authorization' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Invitation Letter%' THEN 'Invitation Letter'
       WHEN oi.visa_category LIKE 'United States DV Lottery Entry Form' THEN 'Application Prep'
       WHEN oi.visa_category LIKE 'United Kingdom Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'US Virgin Islands Travel Screening (USIV)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Turks & Caicos Islands Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Turkey Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Switzerland Entry Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Singapore Air Travel Pass' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Seychelles Travel Authorization | COVID-19 Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Senegal Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Saint Vincent & Grenadines Pre-Arrival Travel Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Saint Lucia Travel Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Rwanda Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Portugal Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Philippines e-CIF' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Panama Electronic Affidavit' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Oman Traveler Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Nepal International Traveller Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Montserrat Access Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Malta Travel Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Madagascar Landing Authorization' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Latvia COVID Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Jamaica Travel Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Ivory Coast Air Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Italy Self Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Ireland COVID-19 Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'India OCI Card' THEN 'Application Prep'
       WHEN oi.visa_category LIKE 'Iceland Pre-Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Hong Kong Pre-Arrival Registration' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Honduras Pre-Check Application' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Guyana Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Greece Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Germany Digital Registration on Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Georgia Pre-Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'France Travel Certificate' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Estonia Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Egypt Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Dominican Republic eTicket' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Czech Republic Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Cyprus Flight Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Curacao Immigration Card + Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Croatia Announcement Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Colombia Check-MIG Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Cape Verde Pre-Arrival Registration' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Canada ArriveCAN' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Bolivia Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Bermuda Travel Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Belgium Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Barbados ED Card (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Australia Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Aruba ED Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Angola Travel Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Access Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Air Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Announcement Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ArriveCAN' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Attestation Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Check-MIG Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'COVID Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Covid-19 MOPH Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'COVID-19 Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Digital Registration on Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'e-CIF' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ED Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ED Card (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Electronic Affidavit' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Entry Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Entry Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'eTicket' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ETIS' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Flight Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Hawaii Travel and Health Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Alert Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Control Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration (T8 Form)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Form (CNMI)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Pass + Insurance' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Questionnaire' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Surveillance Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Immigration Card + Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Immigration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'International Traveller Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Macao Health Code' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Medical Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'New York Traveler Health Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Form (Covid-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Arrival Travel Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Check Application' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Public Health Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Public Health Passenger Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Self Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Self-Assessment Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'SG Arrival Card + Health Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Sumut Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Surveillance and Health Control Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Authorisation' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Authorization | COVID-19 Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Certificate' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Health Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Screening (USIV)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Accommodation Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Health Declaration (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Health Questionnaire' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Registration Form' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'Israel Inbound Passenger Statement' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'Pakistan Pass Track' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'India OCI Card for UK and the UAE Nationals' THEN 'eVisa'
       WHEN o.visa_category LIKE 'Cayman Islands Travel Application' THEN 'eVisa'
       WHEN o.visa_category LIKE 'Bermuda 1 Year Residential Certificate' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Affidavit (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%Health Declaration%' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Visitor Application Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%Health%' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%eVisa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%e-Visa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Visa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ETA%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ESTA%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%eVisitor%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%EVUS%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ETIS%' THEN 'eVisa' ELSE oi.visa_category END AS product_category,
       #Date fomats
       CAST(CASE WHEN oi.closed_at IS NULL THEN oi.processing_deadline
                 WHEN oi.closed_at >= oi.processing_deadline THEN oi.processing_deadline ELSE oi.closed_at END AS DATE) AS date_cons,
       DAYOFWEEK(CAST(CASE WHEN oi.closed_at IS NULL THEN oi.processing_deadline
                           WHEN oi.closed_at >= oi.processing_deadline THEN oi.processing_deadline ELSE oi.closed_at END AS DATE))-1 AS day_of_week,
       DATEDIFF(CAST(oi.processing_deadline AS DATE), oi.created_at) AS datediff_deadline_created
FROM reporting.orders o
JOIN (SELECT * FROM reporting.order_items WHERE reporting.order_items.type = "visa" or reporting.order_items.type = "health_declaration") AS oi ON o.order_id = oi.order_id AND o.order_type = oi.type
LEFT JOIN reporting.order_timing ot ON o.order_id = ot.order_id




CASE
       WHEN oi.type = 'passport_photo' THEN 'Photo'
       WHEN oi.type = 'embassy_reg' THEN 'Emb_reg'
       WHEN oi.visa_category LIKE '%Tourist Card%' THEN 'Arrival Card'
       WHEN oi.visa_category LIKE '%Arrival Card%' THEN 'Arrival Card'
       WHEN oi.visa_category LIKE '%Mexico Electronic Authorization' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Invitation Letter%' THEN 'Invitation Letter'
       WHEN oi.visa_category LIKE 'United States DV Lottery Entry Form' THEN 'Application Prep'
       WHEN oi.visa_category LIKE 'United Kingdom Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'US Virgin Islands Travel Screening (USIV)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Turks & Caicos Islands Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Turkey Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Switzerland Entry Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Singapore Air Travel Pass' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Seychelles Travel Authorization | COVID-19 Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Senegal Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Saint Vincent & Grenadines Pre-Arrival Travel Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Saint Lucia Travel Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Rwanda Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Portugal Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Philippines e-CIF' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Panama Electronic Affidavit' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Oman Traveler Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Nepal International Traveller Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Montserrat Access Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Malta Travel Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Madagascar Landing Authorization' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Latvia COVID Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Jamaica Travel Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Ivory Coast Air Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Italy Self Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Ireland COVID-19 Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'India OCI Card' THEN 'Application Prep'
       WHEN oi.visa_category LIKE 'Iceland Pre-Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Hong Kong Pre-Arrival Registration' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Honduras Pre-Check Application' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Guyana Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Greece Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Germany Digital Registration on Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Georgia Pre-Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'France Travel Certificate' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Estonia Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Egypt Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Dominican Republic eTicket' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Czech Republic Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Cyprus Flight Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Curacao Immigration Card + Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Croatia Announcement Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Colombia Check-MIG Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Cape Verde Pre-Arrival Registration' THEN 'Pre-Arrival Authorization'
       WHEN oi.visa_category LIKE 'Canada ArriveCAN' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Bolivia Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Bermuda Travel Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Belgium Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Barbados ED Card (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Australia Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Aruba ED Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Angola Travel Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Access Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Air Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Announcement Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ArriveCAN' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Attestation Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Check-MIG Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'COVID Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Covid-19 MOPH Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'COVID-19 Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Digital Registration on Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'e-CIF' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ED Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ED Card (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Electronic Affidavit' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Entry Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Entry Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'eTicket' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'ETIS' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Flight Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Hawaii Travel and Health Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Alert Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Authorization' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Control Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration (T8 Form)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Declaration Form (CNMI)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Pass' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Pass + Insurance' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Questionnaire' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Health Surveillance Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Immigration Card + Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Immigration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'International Traveller Arrival Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Macao Health Code' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Medical Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'New York Traveler Health Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Passenger Locator Form (Covid-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Arrival Travel Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Check Application' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Pre-Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Public Health Locator Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Public Health Passenger Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Self Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Self-Assessment Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'SG Arrival Card + Health Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Sumut Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Surveillance and Health Control Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Authorisation' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Authorization | COVID-19 Entry' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Certificate' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Declaration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Health Card' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Registration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Travel Screening (USIV)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Accommodation Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Declaration Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Health Declaration (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Health Questionnaire' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Registration' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Traveler Registration Form' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'Israel Inbound Passenger Statement' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'Pakistan Pass Track' THEN 'Health Declaration'
       WHEN o.visa_category LIKE 'India OCI Card for UK and the UAE Nationals' THEN 'eVisa'
       WHEN o.visa_category LIKE 'Cayman Islands Travel Application' THEN 'eVisa'
       WHEN o.visa_category LIKE 'Bermuda 1 Year Residential Certificate' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Affidavit (COVID-19)' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%Health Declaration%' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE 'Visitor Application Form' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%Health%' THEN 'Health Declaration'
       WHEN oi.visa_category LIKE '%eVisa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%e-Visa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%Visa%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ETA%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ESTA%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%eVisitor%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%EVUS%' THEN 'eVisa'
       WHEN oi.visa_category LIKE '%ETIS%' THEN 'eVisa' ELSE oi.visa_category END AS product_category
