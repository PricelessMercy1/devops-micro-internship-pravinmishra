---
name: cloudfront-priceclass-recommendation
description: Portfolio site currently uses PriceClass_200 in ap-south-1; can optimize to PriceClass_100 for ~50% savings
metadata:
  type: feedback
---

**Recommendation**: Reduce CloudFront PriceClass from 200 to 100

**Why**: Static portfolio website doesn't require global edge location coverage. PriceClass_100 covers North America, Europe, and parts of Asia—sufficient for a portfolio site. PriceClass_200 adds additional edge locations at 2x the cost for minimal benefit on static content.

**How to apply**: Change line 62 in terraform/main.tf from `price_class = "PriceClass_200"` to `price_class = "PriceClass_100"`

**Estimated Impact**: ~50% reduction in CloudFront pricing tier costs (~$20-30/month savings depending on traffic patterns)

**Caveat**: If analytics show primary traffic from regions not in PriceClass_100 coverage, revert to PriceClass_200. Monitor CloudFront metrics after change.
