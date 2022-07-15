module.exports = (id, startdate, enddate) => {
  qualifier = { }
  if(startdate) qualifier['P580'] = startdate
  if(enddate)   qualifier['P582'] = enddate

  return {
    id,
    claims: {
      P39: {
        value: 'Q44035369',
        qualifiers: qualifier,
        references: { P4656: 'https://be.wikipedia.org/wiki/%D0%9C%D1%96%D0%BD%D1%96%D1%81%D1%82%D1%8D%D1%80%D1%81%D1%82%D0%B2%D0%B0_%D0%B0%D0%B1%D0%B0%D1%80%D0%BE%D0%BD%D1%8B_%D0%A0%D1%8D%D1%81%D0%BF%D1%83%D0%B1%D0%BB%D1%96%D0%BA%D1%96_%D0%91%D0%B5%D0%BB%D0%B0%D1%80%D1%83%D1%81%D1%8C' }
      }
    }
  }
}
