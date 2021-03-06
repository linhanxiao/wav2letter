-- Copyright (c) 2017-present, Facebook, Inc.
-- All rights reserved.

-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. An additional grant
-- of patent rights can be found in the PATENTS file in the same directory.

local tnt = require 'torchnet'
local argcheck = require 'argcheck'
local utils = require 'wav2letter.utils'

local EditDistanceMeter = torch.class('tnt.EditDistanceMeter', 'tnt.Meter', tnt)

EditDistanceMeter.__init = argcheck{
   {name="self", type="tnt.EditDistanceMeter"},
   call =
      function(self)
         self:reset()
      end
}

EditDistanceMeter.reset = argcheck{
   {name="self", type="tnt.EditDistanceMeter"},
   call =
      function(self)
         self.sum = 0
         self.n = 0
      end
}

EditDistanceMeter.add = argcheck{
   {name="self", type="tnt.EditDistanceMeter"},
   {name="output", type="torch.*Tensor"},
   {name="target", type="torch.*Tensor"},
   call =
      function(self, output, target)
         assert(target:nDimension() <= 1, 'target: vector expected')
         assert(output:nDimension() <= 1, 'output: vector expected')
         self.sum = self.sum + utils.editdistance(output:long(), target:long())
         self.n = self.n + (target:nDimension() > 0 and target:size(1) or 0)
      end
}

EditDistanceMeter.value = argcheck{
   {name="self", type="tnt.EditDistanceMeter"},
   call =
      function(self)
         return self.sum / self.n * 100
      end
}

EditDistanceMeter.reduce = argcheck{
   {name="self", type="tnt.EditDistanceMeter"},
   {name="reduce", type="function"},
   call =
      function(self, reduce)
         self.sum = reduce(self.sum, true)
         self.n = reduce(self.n, true)
         return self
      end
}
