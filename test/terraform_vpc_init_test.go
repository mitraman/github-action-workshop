package test

/* this is based on the terratest example at https://github.com/gruntwork-io/terratest/blob/master/test/terraform_aws_network_example_test.go */
// Let the reader know that they can uses these examples as a template for their own tests

// Should call out that the impact of using terraform and terratest is that we will need to have people
// in our 'pod' that are skilled in terraform and Go lang

/* how much Go lang does the reader need to understand? Where can they go to get up to speed? */

/* where can the reader see what modules are needed?*/
import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

/* talk about testing basics in go - e.g. https://blog.alexellis.io/golang-writing-unit-tests/ */

/* How do funcs and args work in Golang? Discuss the go test command and how it is in-built for Golang */
func TestTerraformHelloWorldExample(t *testing.T) {
	t.Parallel()

	// TK consider changing this to a specific region for simplicity
	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// TK why is this defines as vars? why not in the tf? need to look at TF best practices to understand this properly.
	// ... assume this is so you can use the same TF across different environs
	// Give the VPC and the subnets correct CIDRs
	vpcCidr := "10.10.0.0/16"
	privateSubnetCidr := "10.10.1.0/24"
	publicSubnetCidr := "10.10.2.0/24"

	// NOTE: good tips on VPC design here: https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc#.bmeh8m3si	

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/network",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"main_vpc_cidr":       vpcCidr,
			"private_subnet_cidr": privateSubnetCidr,
			"public_subnet_cidr":  publicSubnetCidr,
			"aws_region":          awsRegion,
		},
	}

	/* will need to explain to the reader wihat Go defer means*/
	defer terraform.Destroy(t, terraformOptions)

	/* should outline for the reader the most important terrraform API calls - e.g. is it allwyays destory and init? */
	terraform.InitAndApply(t, terraformOptions)
	

	/* our tests go here...*/

	// Get values from the output - this means our terraform scripts must output values to make them testable
	vpcID := terraform.Output(t, terraformOptions, "main_vpc_id")

	// Make a call to AWS and retrieve the subnets for our VPC id
	subnets := aws.GetSubnetsForVpc(t, vpcId, awsRegion)

	// Verify that we have two subnets defined in our VPC
	require.Equal(t, 2, len(subnets))

	// Verify if the network that is supposed to be public is really public
	assert.True(t, aws.IsPublicSubnet(t, publicSubnetId, awsRegion))

	// Verify if the network that is supposed to be private is really private
	assert.False(t, aws.IsPublicSubnet(t, privateSubnetId, awsRegion))
	
}