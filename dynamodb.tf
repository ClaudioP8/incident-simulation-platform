resource "aws_dynamodb_table" "orders" {
  name         = "incident-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  tags = {
    Project = "IncidentSimulationPlatform"
    Layer   = "Data"
  }
}
