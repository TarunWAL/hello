#ecr repository

resource "aws_ecr_repository" "foo" {
  name                 = "bar" #(Required)
  image_tag_mutability = "MUTABLE" #optional

  image_scanning_configuration { #Optional
    scan_on_push = true  #required
  }
}
#name -  Name of the repository.

#encryption_configuration - Encryption configuration for the repository.

#encryption_type - The encryption type to use for the repository. Valid values are AES256 or KMS. Defaults to AES256.

#kms_key -  The ARN of the KMS key to use when encryption_type is KMS. If not specified, uses the default AWS managed key for ECR.

#image_tag_mutability - The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE

#image_scanning_configuration - (Optional) Configuration block that defines image scanning configuration for the repository. By default, image scanning must be manually triggered. 

#scan_on_push - (Required) Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)

# we can keep tag optional
