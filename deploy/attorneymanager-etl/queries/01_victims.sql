-- Selects all victims from cases along with their phone/address/case numbers.
-- TODO: Only select one row per case rather than one per charge.
--
-- TODO: fetch CaseCrossReferences for each case
-- TODO: many victims have multiple DA Case Numbers for the same case. What is
-- the proper user experience in that situation (one email that has three case
-- numbers or three separate emails).
--
-- Cross Reference Type ID 10365 = "Court Case Number"

WITH cases_updated_90days AS (SELECT        CaseID, MAX(EventDate) AS UpdatedAt
                                                                          FROM            CaseEvent
                                                                          WHERE        (DATEADD(month, - 2, GETDATE()) < EventDate) AND (EventDate < GETDATE())
                                                                          GROUP BY CaseID)
    SELECT        CaseParty.PartyID, CaseParty.CaseID, Name.NameFirst, Name.NameLast, Party.Email, Name.fInactive AS NameInactive, Addr.AddressID, Addr.Address1, Addr.Address2, Addr.City, Addr.State, Addr.ZIP,
                              Addr.fInvalidAddr AS AddrInactive, DOB.Inactive AS DOBInactive, Phone_1.PhoneNum AS PhoneNumHome, Phone_1.PhoneExt AS PhoneExtHome, Phone.PhoneNum AS PhoneNumCell,
                              Phone.PhoneExt AS PhoneExtCell, CaseAssignHist.CaseNbr AS DACaseNumber,
                              CasePartyConn.BaseConnKy, CasePartyConn.CasePartyConnID, cases_updated_90days_1.UpdatedAt AS LastCaseEventDate
     FROM            CaseParty INNER JOIN
                              Party ON CaseParty.PartyID = Party.PartyID INNER JOIN
                              CaseAssignHist ON CaseParty.CaseID = CaseAssignHist.CaseID INNER JOIN
                              Name ON Party.NameIDCur = Name.NameID AND Name.NameFirst IS NOT NULL INNER JOIN
                              cases_updated_90days AS cases_updated_90days_1 ON CaseParty.CaseID = cases_updated_90days_1.CaseID LEFT OUTER JOIN
                              Phone ON Party.PhoneIDCellCur = Phone.PhoneID INNER JOIN
                              CasePartyConn ON CaseParty.CasePartyID = CasePartyConn.CasePartyID AND CasePartyConn.BaseConnKy = 'VI' LEFT OUTER JOIN
                              Phone AS Phone_1 ON Party.PhoneIDHmCur = Phone_1.PhoneID LEFT OUTER JOIN
                              Addr ON Party.AddrIDHmCur = Addr.AddressID LEFT OUTER JOIN
                              DOB ON Party.DOBIDCur = DOB.DOBID
