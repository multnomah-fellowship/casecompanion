-- Selects all victims from cases along with their phone/address/case numbers.
-- TODO: Only select one row per case rather than one per charge.
--
-- Cross Reference Type ID 10365 = "Court Case Number"

SELECT        CaseParty.PartyID, CaseParty.CaseID, xChrgVictim.ChargeID, Name.NameFirst, Name.NameLast, Party.Email, Name.fInactive AS NameInactive, Addr.AddressID, Addr.Address1, Addr.Address2, Addr.City,
                         Addr.State, Addr.ZIP, Addr.fInvalidAddr AS AddrInactive, DOB.Inactive AS DOBInactive, Phone_1.PhoneNum AS PhoneNumHome, Phone_1.PhoneExt AS PhoneExtHome, Phone.PhoneNum AS PhoneNumCell,
                         Phone.PhoneExt AS PhoneExtCell, CaseAssignHist.CaseNbr AS DACaseNumber, CaseAssignHist.ManualCaseNbr, CaseAssignHist.CaseNbrSrch, CaseAssignHist.NodeID, CasePartyConn.AsAttorney,
                         CasePartyConn.AsParticipant, CasePartyConn.ExtConnID, CasePartyConn.BaseConnKy, CasePartyConn.CasePartyConnID, CasePartyConn.TimestampChange AS CasePartyConnTimestampChange,
                         CourtCaseNumberCrossReference.CrossReferenceNumber AS CourtCaseNumber
FROM            xChrgVictim INNER JOIN
                         CaseParty ON xChrgVictim.CasePartyID = CaseParty.CasePartyID INNER JOIN
                         Party ON CaseParty.PartyID = Party.PartyID INNER JOIN
                         CaseAssignHist ON CaseParty.CaseID = CaseAssignHist.CaseID LEFT OUTER JOIN
                         Phone ON Party.PhoneIDCellCur = Phone.PhoneID LEFT OUTER JOIN
                         CaseCrossReference AS CourtCaseNumberCrossReference ON CaseParty.CaseID = CourtCaseNumberCrossReference.CaseID AND
                         CourtCaseNumberCrossReference.CrossReferenceTypeID = 10365 LEFT OUTER JOIN
                         CasePartyConn ON CaseParty.CasePartyID = CasePartyConn.CasePartyID LEFT OUTER JOIN
                         Name ON Party.NameIDCur = Name.NameID LEFT OUTER JOIN
                         Phone AS Phone_1 ON Party.PhoneIDHmCur = Phone_1.PhoneID LEFT OUTER JOIN
                         Addr ON Party.AddrIDHmCur = Addr.AddressID LEFT OUTER JOIN
                         DOB ON Party.DOBIDCur = DOB.DOBID
