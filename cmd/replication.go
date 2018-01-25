// Copyright © 2017-2018 Giuseppe Maxia
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cmd

import (
	//"fmt"

	"dbdeployer/sandbox"
	"github.com/spf13/cobra"
)

func ReplicationSandbox(cmd *cobra.Command, args []string) {
	var sd sandbox.SandboxDef
	sd = FillSdef(cmd, args)
	sd.ReplOptions = sandbox.ReplOptions
	flags := cmd.Flags()
	nodes, _ := flags.GetInt("nodes")
	topology, _ := flags.GetString("topology")
	sandbox.CreateReplicationSandbox(sd, args[0], topology, nodes)
}

// replicationCmd represents the replication command
var replicationCmd = &cobra.Command{
	Use:   "replication MySQL-Version",
	Args:  cobra.ExactArgs(1),
	Short: "create replication sandbox",
	Long:  ``,
	Run:   ReplicationSandbox,
}

func init() {
	rootCmd.AddCommand(replicationCmd)
	replicationCmd.PersistentFlags().String("topology", "master-slave", "Which topology will be installed")
	replicationCmd.PersistentFlags().Int("nodes", 3, "How many nodes will be installed")
	//replicationCmd.PersistentFlags().Int("slaves",  2, "How many slaves will be installed")
}