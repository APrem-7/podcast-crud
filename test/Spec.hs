module Main (main) where

import Test.Hspec

main :: IO ()
main = hspec $
  describe "sanity" $
    it "runs the test suite" $
      (1 + 1 :: Int) `shouldBe` 2
