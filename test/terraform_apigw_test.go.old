package test

/* this is based on the terratest example at https://github.com/gruntwork-io/terratest/blob/master/test/terraform_aws_network_example_test.go */
// Let the reader know that they can uses these examples as a template for their own tests

// Should call out that the impact of using terraform and terratest is that we will need to have people
// in our 'pod' that are skilled in terraform and Go lang

/* how much Go lang does the reader need to understand? Where can they go to get up to speed? */

/* where can the reader see what modules are needed?*/
import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	//"github.com/stretchr/testify/assert"
	//"github.com/stretchr/testify/require"
)

/* talk about testing basics in go - e.g. https://blog.alexellis.io/golang-writing-unit-tests/ */

/* How do funcs and args work in Golang? Discuss the go test command and how it is in-built for Golang */
func TestTerraformAPIGW(t *testing.T) {
	t.Parallel()

	// TK consider changing this to a specific region for simplicity
	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	
	// NOTE: good tips on VPC design here: https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc#.bmeh8m3si	

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/apigw",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{			
			"aws_region":          awsRegion,
		},
	}

	/* will need to explain to the reader wihat Go defer means*/
	defer terraform.Destroy(t, terraformOptions)

	/* should outline for the reader the most important terrraform API calls - e.g. is it allwyays destory and init? */
	terraform.InitAndApply(t, terraformOptions)
	

	/* our tests go here...*/
	// TODO: SHould this go into a validate function?

	
}